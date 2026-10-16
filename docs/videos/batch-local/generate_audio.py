import json,re,wave,os
from pathlib import Path
import numpy as np
from kokoro_onnx import Kokoro
root=Path(__file__).parent
k=Kokoro(str(root/'models/kokoro.onnx'),str(root/'models/voices.bin'))
prod=json.loads((root/'production.json').read_text())
replacements={'FileNotFoundError':'file not found error','AssertionError':'assertion error','TypeError':'type error','json.loads':'jêison loads','arquivo.write':'arquivo ponto write','configuracao.txt':'configuração ponto tê xis tê','aviso.py':'aviso ponto pai','self.segundos_restantes':'self ponto segundos restantes','segundos_restantes':'segundos restantes','__init__':'init','git':'guít','Git':'Guít','GitHub':'Guít Hub','SQLite':'ésse quiu lite','Python':'Páiton','JSON':'jêison','CRUD':'crud','UTF oito':'u tê éfe oito'}
for lesson in prod['lessons']:
 n=lesson['module'];out=root/f'lesson-{n}';out.mkdir(exist_ok=True)
 if (out/'timeline.json').exists():continue
 chunks=[];timeline=[];clock=0.;sr=24000
 def append(samples,scene,text,kind):
  global clock
  dur=len(samples)/sr;timeline.append(dict(start=clock,end=clock+dur,scene=scene,text=text,kind=kind));chunks.append(samples);clock+=dur
 append(np.zeros(sr*2,dtype=np.float32),0,'Prepare-se para observar, prever e testar.','pause')
 for i,scene in enumerate(lesson['scenes']):
  # Sentence boundaries keep full punctuation; periods within identifiers stay intact.
  sentences=re.split(r'(?<=[.!?])\s+(?=[A-ZÁÉÍÓÚÂÊÔÃÕÇ])',scene['narration'])
  for sentence in sentences:
   spoken=sentence
   for a,b in replacements.items():spoken=spoken.replace(a,b)
   a,sr=k.create(spoken,voice='pf_dora',speed=.75,lang='pt-br')
   append(a,i,sentence,'speech')
   append(np.zeros(int(sr*.55),dtype=np.float32),i,'','pause')
  append(np.zeros(sr*6,dtype=np.float32),i,'Pause e confira o código e o resultado.','pause')
 if clock<180:append(np.zeros(int(sr*(180-clock)),dtype=np.float32),4,'Faça sua previsão antes de voltar à prática.','pause')
 with wave.open(str(out/'narracao.wav'),'wb') as w:
  w.setparams((1,2,sr,0,'NONE','not compressed'));w.writeframes((np.clip(np.concatenate(chunks),-1,1)*32767).astype('int16').tobytes())
 (out/'timeline.json').write_text(json.dumps(timeline,ensure_ascii=False,indent=2))
 print(f'Aula {n}: {clock:.2f}s; {len(timeline)} trechos',flush=True)
