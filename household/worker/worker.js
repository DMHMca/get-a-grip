// Household store: one JSON document per household code, kept in Cloudflare KV.
// GET  /h/<code>            -> {v, doc} or 404
// PUT  /h/<code> {base,doc} -> saves if base matches the stored version, else 409 with the current copy
const ORIGINS = ['https://dmhmca.github.io'];
export default {
  async fetch(req, env) {
    const origin = req.headers.get('Origin') || '';
    const cors = {
      'Access-Control-Allow-Origin': ORIGINS.includes(origin) ? origin : ORIGINS[0],
      'Access-Control-Allow-Methods': 'GET,PUT,OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Vary': 'Origin'
    };
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors });
    const m = new URL(req.url).pathname.match(/^\/h\/([A-Z0-9]{12})$/);
    const j = (o, s) => new Response(JSON.stringify(o), { status: s || 200, headers: { ...cors, 'Content-Type': 'application/json' } });
    if (!m) return j({ error: 'not found' }, 404);
    const key = 'h:' + m[1];
    const cur = await env.HOUSEHOLD.get(key, 'json');
    if (req.method === 'GET') return cur ? j(cur) : j({ error: 'none' }, 404);
    if (req.method === 'PUT') {
      const text = await req.text();
      if (text.length > 400000) return j({ error: 'too big' }, 413);
      let body; try { body = JSON.parse(text); } catch (e) { return j({ error: 'bad json' }, 400); }
      if (!body || typeof body.doc !== 'object') return j({ error: 'bad body' }, 400);
      const have = cur ? cur.v : 0;
      if ((body.base || 0) !== have) return j(cur, 409);
      const next = { v: have + 1, doc: body.doc };
      await env.HOUSEHOLD.put(key, JSON.stringify(next));
      return j({ v: next.v });
    }
    return j({ error: 'method' }, 405);
  }
};
