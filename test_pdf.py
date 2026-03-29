import database; import pdf_generator; import json

old_multi_cell = pdf_generator.FPDF.multi_cell
def new_multi_cell(self, w, h, txt, *args, **kwargs):
    print(f"MULTI_CELL -> x:{self.get_x()}, y:{self.get_y()}, margins:(L:{self.l_margin}, R:{self.r_margin}), txt='{txt[:20]}...'")
    old_multi_cell(self, w, h, txt, *args, **kwargs)
pdf_generator.FPDF.multi_cell = new_multi_cell

conn = database.get_db_connection()
fb = conn.execute('SELECT * FROM feedbacks ORDER BY id DESC LIMIT 1').fetchone()
fb_dict = dict(fb)
if fb_dict.get('impacts_json'): fb_dict['impacts'] = json.loads(fb_dict['impacts_json'])
history_rows = conn.execute('SELECT * FROM feedbacks WHERE engineer_name = ?', (fb_dict['engineer_name'],)).fetchall()
fb_dict['history'] = [dict(h) for h in history_rows]

try:
    pdf_generator.generate_pdf(fb_dict, '/tmp/test.pdf')
    print('Sucesso')
except Exception as e:
    import traceback
    traceback.print_exc()
