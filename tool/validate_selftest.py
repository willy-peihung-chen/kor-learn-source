"""偵測工具的自我測試：故意放錯的句子要全部被抓到，正確的句子不能誤報。用法：python tool/validate_selftest.py"""
import sys
sys.path.insert(0, __import__("os").path.dirname(__import__("os").path.abspath(__file__)))
import validate_content as v
words=v.load_words(); nouns={w.hangul for w in words if not w.hangul.endswith('다') and ' ' not in w.hangul}
bad=['구 시에 만나요.','삼 월에 와요.','저는 의사이에요.','저는 학생예요.','학교을 가요.','도서관를 가요.','춤을 출수 있어요.','할 수있어요.','자고있어요.','안되요.','몇일이에요?','학생이예요.','세 층이에요.','하나 개 주세요.','서울으로 가요.','사과 다섯 원이에요.','먹을것이 있어요.','제가 올께요.','먹을께요.','이 번째예요.','두 분 후에 만나요.']
good=['아홉 시에 만나요.','삼월에 와요.','저는 의사예요.','저는 학생이에요.','학교에 가요.','춤을 출 수 있어요.','자고 있어요.','안 돼요.','며칠이에요?','삼 층이에요.','한 개 주세요.','서울로 가요.','사과가 백 개 있어요.','아이예요.','지하철로 가요.','이것은 뭐예요?','제가 할게요.','두 번째예요.','첫 번째예요.','감사합니다. 또 올게요.','두 분이세요?','세 분께서 오셨어요.']
miss=[]
for t in bad:
    r=v.Report(); v.lint_korean(t,'x',r,sentence=True); v.lint_particles(t,nouns,'x',r)
    if not r.issues: miss.append(t)
fp=[]
for t in good:
    r=v.Report(); v.lint_korean(t,'x',r,sentence=True); v.lint_particles(t,nouns,'x',r)
    if r.issues: fp.append((t,[i.message for i in r.issues]))
print('漏抓:',miss); print('誤報:',fp)
# 說明文字：「不要寫成」後面的錯誤寫法不算錯，但其他地方的錯誤仍要抓到。
desc_bad=['의사이에요（醫生）。','학생예요。','몇일이에요?','不要寫成 의사이에요，正確是 학생예요','不要寫成 몇일；例：학생예요']
desc_good=['容易寫錯：不要寫成 의사이에요、학생예요、의사이 아니에요；아니에요 也不要寫成 아니예요。','・의사 的「사」沒有收尾音 → 의사예요','ㄹ 收尾的字最容易錯：不要寫成 지하철으로、연필으로。']
desc_miss=[]
desc_fp=[]
for t in desc_bad:
    r=v.Report(); v.lint_korean(t,'x',r,sentence=False)
    if not r.issues: desc_miss.append(t)
for t in desc_good:
    r=v.Report(); v.lint_korean(t,'x',r,sentence=False)
    if r.issues: desc_fp.append((t,[i.message for i in r.issues]))
print('說明文字 漏抓:',desc_miss); print('說明文字 誤報:',desc_fp)
# 單元規則：單元 1～10 不可插入文法庫的卡片（要寫在說明卡、用 grammarRefs 連過去）。
units=v.load_units(); grammar=v.load_grammar()
rule_miss=[]
for n in (6, 10):
    us=v.load_units()
    us[n-1].cards.insert(1, v.Card(id='grammar:wa_gwa', kind='grammar', grammar_id='wa_gwa'))
    r=v.Report(); v.check_units(us, words, grammar, r)
    if not any('不要插入文法庫的卡片' in i.message for i in r.issues): rule_miss.append(n)
r=v.Report(); v.check_units(units, words, grammar, r)
rule_fp=[i.message for i in r.issues]
print('單元文法卡規則 漏抓:',rule_miss); print('單元文法卡規則 誤報:',rule_fp)

# 單字等級表：多出單字庫沒有的字、等級不是 1/2、與詞表不一致都要抓到；現有資料不能誤報。
import re as _re
real=open(__import__("os").path.join(v.DATA,'word_level_data.dart'),encoding='utf-8').read()
import gen_word_levels as _g
exp=_g.expected()
lv_cases={
 '多出單字庫沒有的字': (real.replace("'가다': 1,","'가다': 1, '없는단어': 1,"), None, '不在單字庫'),
 '等級是 3': (real.replace("'가다': 1,","'가다': 3,"), None, '只能記 1 或 2'),
 }
if exp is not None:
    lv_cases['與詞表不一致']=(real.replace("'가다': 1,","'가다': 2,"), exp, '不一致')
lv_miss=[]
for name,(data,e,key) in lv_cases.items():
    r=v.Report(); v.check_word_levels(words,r,data=data,expected=e)
    if not any(key in i.message for i in r.issues): lv_miss.append(name)
r=v.Report(); v.check_word_levels(words,r)
lv_fp=[i.message for i in r.issues if i.level=='ERROR']
print('單字等級 漏抓:',lv_miss); print('單字等級 誤報:',lv_fp, '（詞表比對：', '有' if exp else '沒有', '）')
# Dart 結構：多打逗號、漏打括號要抓到；正常的尾隨逗號不能誤報。
import tempfile, os as _os
def _dart(src):
    fd, path = tempfile.mkstemp(suffix='.dart'); _os.close(fd)
    open(path, 'w', encoding='utf-8').write(src)
    r = v.Report(); v.check_dart_structure(path, r); _os.remove(path)
    return r.issues
dart_bad = ["const a = W('x', 'y', , note: 'z');", "const a = W(, 'x');", "const a = W('x', 'y';"]
dart_good = ["const a = W('x', 'y', note: 'a, , b');", "const a = <W>[\n  W('x', 'y',),\n];", "const a = W('x', 'y');"]
dart_miss = [t for t in dart_bad if not _dart(t)]
dart_fp = [t for t in dart_good if _dart(t)]
print('Dart 結構 漏抓:', dart_miss); print('Dart 結構 誤報:', dart_fp)
