import fs from 'node:fs';
export default async ({project})=>{
 const root=process.env.LESSON_ROOT;
 if(!root)throw Error('Set LESSON_ROOT');
 const d=JSON.parse(fs.readFileSync(root+'/production.json'));
 const ck=JSON.parse(fs.readFileSync(root+'/clock.json'));
 const duration=Number(JSON.parse(fs.readFileSync(root+'/probe.json')).format.duration);
 const norm=s=>s.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9]/g,'');
 const words=ck.captions.flatMap(c=>c.text.split(/\s+/).map(w=>({w:norm(w),at:c.start})));
 let after=-1;
 const starts=d.states.map((s,i)=>{const q=s[0].split(/\s+/).map(norm);for(let j=0;j<=words.length-q.length;j++){if(words[j].at>after&&q.every((v,k)=>v===words[j+k].w)){after=words[j].at;return i?after:0;}}throw Error('Missing cue '+s[0]);});
 starts.push(duration);
 const p=await project({dir:root+'/project',size:'1920x1080',fps:24,background:'#101827'});
 const a=await p.add(root+'/narration.mp3');p.cut(a,{at:0,from:0,dur:duration});
 const R=(x,y,w,h,fill='#18253B',radius=18)=><rect x={x} y={y} width={w} height={h} fill={fill} radius={radius}/>;
 const T=(s,x,y,sz=36,col='#EEF4FF',w=1660,font='Inter',h=150)=><text x={x} y={y} width={w} height={h} fontSize={sz} fontFamily={font} color={col}>{s}</text>;
 const cursor=(x,y)=><path x={x} y={y} width={28} height={38} d="M0 0 L0 31 L8 23 L15 37 L22 33 L14 20 L27 20 Z" fill="#FFFFFF" stroke={{color:'#101827',width:2}}/>;
 for(let i=0;i<d.states.length;i++){
  const [cue,title,code,out,note,focus,cards]=d.states[i];
  const nodes=[R(0,0,1920,1080,'#101827',0),R(90,67,7,35,'#55D9E8',3),T('CÓDIGO ZERO',114,66,25,'#55D9E8'),T('AULA '+d.module+'.1  ·  '+String(i+1).padStart(2,'0'),1460,72,20,'#A8B8CF',380),T(title,90,140,55),T('Demonstração didática · saídas conferidas em Python',90,1020,17,'#8B9BB5'),R(90,994,1740*(i+1)/d.states.length,3,'#55D9E8',0)];
  if(code){
   nodes.push(R(90,258,1740,390),T('exemplo.py',120,278,18,'#A8B8CF'),R(1600,272,190,44,'#55D9E8',10),T('Executar',1624,280,20,'#101827',180));
   const lines=code.split('\n');
   if(lines.length>8)throw Error('Too many code lines');
   if(focus>=0)nodes.push(R(152,322+focus*39,1380,39,'#293D58',6));
   lines.forEach((line,n)=>{if(line.length>76)throw Error('Long code line');nodes.push(T(String(n+1),115,325+n*39,23,'#63738C',40,'JetBrains Mono'),T(line,170,325+n*39,31,line.trim().startsWith('#')?'#8B9BB5':'#EEF4FF',1610,'JetBrains Mono',60));});
   if(focus>=0)nodes.push(cursor(1545,330+focus*39));
   const err=/Error|Esperávamos/.test(out);
   nodes.push(R(90,669,1740,180),T(err?'SAÍDA · INVESTIGAÇÃO':'SAÍDA',118,682,17,err?'#FFB4A9':'#A8B8CF'),T(out,120,715,28,err?'#FFB4A9':'#55D9E8',1620,'JetBrains Mono',135));
  }else{
   (cards||[]).forEach((s,n)=>nodes.push(R(90,300+n*145,1740,115),T(s,130,330+n*145,39,n%2?'#EEF4FF':'#55D9E8',1650)));
  }
  nodes.push(T(note,100,862,25,'#B69CFF',1720, 'Inter',60));
  p.compose(nodes,{at:starts[i],dur:starts[i+1]-starts[i],name:title+' '+i});
 }
 fs.writeFileSync(root+'/timing.json',JSON.stringify({starts,duration},null,2));
 await p.frame(starts[Math.floor(d.states.length/2)]+1,root+'/preview.png');
};
