import json,subprocess,re,sys,unicodedata
from pathlib import Path
root=Path(sys.argv[1])
d=json.loads((root/'production.json').read_text())
ck=json.loads((root/'clock.json').read_text())
norm=lambda s: re.sub(r'[^a-z0-9]', '', unicodedata.normalize('NFD',s.lower()).encode('ascii','ignore').decode())
a=d['script'].split();b=' '.join(c['text'] for c in ck['captions']).split()
assert list(map(norm,a))==list(map(norm,b)), 'caption words differ'
assert ck['similarity']>=.9
def probe(n):
 return json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-show_format','-of','json',str(root/n)]))
src=probe('master.mp4');out=probe('final.mp4');voice=probe('narration.mp3')
dur=float(out['format']['duration'])
v=next(s for s in out['streams'] if s['codec_type']=='video')
aout=next(s for s in out['streams'] if s['codec_type']=='audio')
assert abs(float(v['duration'])-float(aout['duration']))<.2
assert abs(dur-float(src['format']['duration']))<1
assert abs(float(aout['duration'])-float(voice['format']['duration']))<.2
caps=ck['captions']; times=[(caps[n]['start']+caps[n]['end'])/2 for n in [5,len(caps)//2,len(caps)-5]]
for i,t in enumerate(times):
 subprocess.run(['ffmpeg','-v','error','-y','-ss',str(t),'-i',str(root/'final.mp4'),'-frames:v','1','-vf','scale=960:-1',str(root/f'qa-{i}.jpg')],check=True)
report={'durationSeconds':dur,'captionWords':len(b),'scriptWords':len(a),'similarity':ck['similarity'],'streamsDurationPassed':True,'sampledFramesSeconds':times,'devicePlayback':'not_tested'}
(root/'validation.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
print(json.dumps(report))
