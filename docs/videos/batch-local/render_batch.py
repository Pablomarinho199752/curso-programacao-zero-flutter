from PIL import Image,ImageDraw,ImageFont
from pathlib import Path
import subprocess,json,textwrap,sys,io
from visuals import VISUALS
root=Path(__file__).parent.resolve();prod=json.loads((root/'production.json').read_text())
font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf';mono='/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'
def f(n,m=False):return ImageFont.truetype(mono if m else font,n)
def srt_time(t):
 ms=round(t*1000);return f'{ms//3600000:02}:{ms//60000%60:02}:{ms//1000%60:02},{ms%1000:03}'
for l in prod['lessons']:
 n=l['module'];out=root/f'lesson-{n}';tp=out/'timeline.json'
 if not tp.exists():continue
 if (out/'validated.json').exists():continue
 timeline=json.loads(tp.read_text());total=timeline[-1]['end'];frames=out/'frames';frames.mkdir(exist_ok=True);concat=[];srt=[];count=0
 for j,item in enumerate(timeline):
  i=item['scene'];code,results=VISUALS[n][i];im=Image.new('RGB',(1280,720),'#0c1220');d=ImageDraw.Draw(im)
  d.text((42,20),f'CÓDIGO ZERO  /  AULA {n}.1',font=f(20),fill='#60e0be');d.text((1045,22),'PRÉVIA • DORA',font=f(16),fill='#a4aec4')
  title=l['scenes'][i]['title'];d.text((42,65),title,font=f(32),fill='white')
  d.rounded_rectangle((36,124,1244,440),14,fill='#141f32',outline='#2c3a52',width=2)
  d.text((58,136),'DEMONSTRAÇÃO  •  '+('GIT' if n==11 else 'PYTHON'),font=f(15),fill='#a4aec4')
  for z,line in enumerate(code):
   y=176+z*40
   d.text((57,y),str(z+1),font=f(20,True),fill='#687990');d.text((94,y),line,font=f(23,True),fill='#c8f0e8')
  d.rounded_rectangle((36,452,1244,554),12,fill='#101927');d.text((58,462),'RESULTADO / OBSERVAÇÃO',font=f(14),fill='#7f91ab')
  for z,line in enumerate(results):d.text((58,489+z*29),line,font=f(21),fill='#f2ce7b')
  text=item['text'];lines=textwrap.wrap(text,width=88)
  # Long sentences split into readable subtitle cards, with proportional timing.
  pages=[lines[a:a+2] for a in range(0,len(lines),2)] or [[]]
  duration=(item['end']-item['start'])/len(pages)
  for pg,lines2 in enumerate(pages):
   img=im.copy();dr=ImageDraw.Draw(img)
   for z,line in enumerate(lines2):dr.text((45,589+z*34),line,font=f(24),fill='white' if item['kind']=='speech' else '#90a3b9')
   t=item['start']+pg*duration;dr.rectangle((0,706,int(1280*t/total),719),fill='#60e0be')
   filename=frames/f'{j:03}-{pg}.png';buf=io.BytesIO();img.save(buf,format="PNG");filename.write_bytes(buf.getvalue());assert filename.stat().st_size>0
   concat.extend([f"file '{filename}'",f'duration {duration:.6f}'])
   if item['kind']=='speech':
    count+=1;srt.append(f'{count}\n{srt_time(t)} --> {srt_time(t+duration)}\n'+ '\n'.join(lines2)+'\n')
  if j==10:im.save(out/'poster.png')
 concat.append(f"file '{filename}'");(out/'frames.txt').write_text('\n'.join(concat));(out/'legendas.srt').write_text('\n'.join(srt))
 subprocess.run(['ffmpeg','-y','-v','error','-f','concat','-safe','0','-i',str(out/'frames.txt'),'-i',str(out/'narracao.wav'),'-t',str(total),'-r','20','-c:v','libx264','-preset','veryfast','-crf','22','-pix_fmt','yuv420p','-c:a','aac','-movflags','+faststart',str(out/f'aula-{n}.mp4')],check=True)
 actual=float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','default=nw=1:nk=1',str(out/f'aula-{n}.mp4')],text=True));assert abs(actual-total)<1,(actual,total)
 (out/'validated.json').write_text(json.dumps({'duration':actual,'voice':'pf_dora','speed':.75,'status':'preview_pending_human_voice_review'}))
 print(f'Aula {n}: render concluído {total:.1f}s',flush=True)
