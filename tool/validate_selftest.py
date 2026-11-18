"""偵測工具的自我測試：故意放錯的句子要全部被抓到，正確的句子不能誤報。用法：python tool/validate_selftest.py"""
import sys
sys.path.insert(0, __import__("os").path.dirname(__import__("os").path.abspath(__file__)))
import validate_content as v
words=v.load_words(); nouns={w.hangul for w in words if not w.hangul.endswith('다') and ' ' not in w.hangul}
bad=['구 시에 만나요.','삼 월에 와요.','저는 의사이에요.','저는 학생예요.','학교을 가요.','도서관를 가요.','춤을 출수 있어요.','할 수있어요.','자고있어요.','안되요.','몇일이에요?','학생이예요.','세 층이에요.','하나 개 주세요.','서울으로 가요.','사과 다섯 원이에요.','먹을것이 있어요.','제가 올께요.','먹을께요.','이 번째예요.']
good=['아홉 시에 만나요.','삼월에 와요.','저는 의사예요.','저는 학생이에요.','학교에 가요.','춤을 출 수 있어요.','자고 있어요.','안 돼요.','며칠이에요?','삼 층이에요.','한 개 주세요.','서울로 가요.','사과가 백 개 있어요.','아이예요.','지하철로 가요.','이것은 뭐예요?','제가 할게요.','두 번째예요.','첫 번째예요.','감사합니다. 또 올게요.']
miss=[]
for t in bad:
    r=v.Report(); v.lint_korean(t,'x',r,sentence=True); v.lint_particles(t,nouns,'x',r)
    if not r.issues: miss.append(t)
fp=[]
for t in good:
    r=v.Report(); v.lint_korean(t,'x',r,sentence=True); v.lint_particles(t,nouns,'x',r)
    if r.issues: fp.append((t,[i.message for i in r.issues]))
print('漏抓:',miss); print('誤報:',fp)
