import fs from 'node:fs';
export default async ({ project }) => {
 const root='/home/user/codigo-zero-pilot';
 const clock=JSON.parse(fs.readFileSync(root+'/clock.json','utf8'));
 const caps=clock.captions; const script=JSON.parse(fs.readFileSync(root+'/script.json','utf8'));
 const norm=s=>s.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9]/g,'');
 const words=[]; for(const c of caps) for(const w of c.text.split(/\s+/)) words.push({w:norm(w),at:c.start});
 function cue(phrase,after=0){const q=phrase.split(/\s+/).map(norm);for(let i=0;i<=words.length-q.length;i++)if(words[i].at>=after&&q.every((v,j)=>words[i+j].w===v)) return words[i].at;throw Error('cue missing: '+phrase);}
 const end=JSON.parse(fs.readFileSync(root+'/probe.json','utf8')).format.duration*1;
 const starts=script.map(x=>cue(x.voice.split(/\s+/).slice(0,5).join(' '))); starts[0]=0;starts.push(end);
 const p=await project({dir:root+'/project',size:'1920x1080',fps:24,background:'#101827'});
 const audio=await p.add(root+'/narration.mp3');p.cut(audio,{from:0,at:0,dur:end});
 const T=(text,x,y,size=36,color='#EEF4FF',width=1640,font='Inter')=><text x={x} y={y} width={width} height={Math.max(size*2.8,150)} fontFamily={font} fontSize={size} color={color}>{text}</text>;
 const R=(x,y,w,h,fill='#18253B',radius=18)=><rect x={x} y={y} width={w} height={h} fill={fill} radius={radius}/>;
 const titles=['Um pedido. Três informações.','Um nome para acessar um valor','Três tipos de informação','Preveja. Execute. Compare.','Com aspas ou sem aspas?','O erro mostra onde investigar','Agora, faça sua previsão'];
 const labels=['01 / CONTEXTO','02 / NOME E VALOR','03 / ATRIBUIÇÃO','04 / EXECUÇÃO','05 / COMPARAÇÃO','06 / ERRO E CORREÇÃO','07 / VOLTE À PRÁTICA'];
 function cursor(x,y){return <path x={x} y={y} width={32} height={42} d="M0 0 L0 34 L9 25 L17 41 L24 37 L16 22 L30 22 Z" fill="#FFFFFF" stroke={{color:'#101827',width:2}}/>;}
 function base(si){return [R(0,0,1920,1080,'#101827',0),R(90,67,7,35,'#55D9E8',3),T('CÓDIGO ZERO',114,66,25,'#55D9E8'),T('AULA 1.1  ·  '+labels[si],1260,72,18,'#A8B8CF',570),T(titles[si],90,140,56),T('Demonstração didática · saídas conferidas em Python',90,1020,17,'#8B9BB5'),R(90,994,1740*(si+1)/7,3,'#55D9E8',0)];}
 function line(code,i,y=316){const tokens=code.match(/"[^"]*"|\b\d+(?:\.\d+)?\b|\bprint\b|[^"\d]+?/g)||[];let x=165;let nodes=[T(String(i+1),115,y+44*i,26,'#63738C',40,'JetBrains Mono')]; for(const token of tokens){let col=token.startsWith('"')?'#55D9E8':/^\d/.test(token)?'#B69CFF':token==='print'?'#E8BC78':'#EEF4FF';nodes.push(T(token,x,y+44*i,34,col,1700-x,'JetBrains Mono'));x+=token.length*20.4;}return nodes;}
 function editor(code,output='',focus=-1,note='',pointer=null,error=false){
  return [R(90,258,1740,370),T('exemplo.py',120,278,18,'#A8B8CF'),R(1600,272,190,46,'#55D9E8',10),T('Executar',1624,281,20,'#101827',180),
   ...(focus>=0?[R(149,312+44*focus,1395,43,'#293D58',7)]:[]),...code.flatMap((l,i)=>line(l,i)),
   R(90,650,1740,190),T(error?'SAÍDA · ERRO NA LINHA 2':'SAÍDA',118,665,17,error?'#FFB4A9':'#A8B8CF'),
   T(output,120,700,30,error?'#FFB4A9':'#55D9E8',1620,'JetBrains Mono'),T(note,100,851,24,'#B69CFF',1720),...(pointer?[cursor(...pointer)]:[])];
 }
 function segment(si,a,b,nodes){if(b<=a)return;p.compose([...base(si),...nodes],{at:a,dur:b-a,name:labels[si]+' '+a.toFixed(2)});}
 // Context: reveal each data card as it is mentioned.
 const s=starts;
 const card=(x,label,value,col)=>[R(x,365,540,330),T(label,x+32,402,25,'#A8B8CF',470),T(value,x+32,475,65,col,470)];
 let q1=cue('qual é o produto'),q2=cue('quantas unidades'),q3=cue('o preço de cada');
 segment(0,0,q1,[T('Como guardar as informações de um pedido?',100,290,35)]);
 segment(0,q1,q2,card(90,'PRODUTO','Suco','#55D9E8'));
 segment(0,q2,q3,[...card(90,'PRODUTO','Suco','#55D9E8'),...card(690,'QUANTIDADE','2','#B69CFF')]);
 segment(0,q3,s[1],[...card(90,'PRODUTO','Suco','#55D9E8'),...card(690,'QUANTIDADE','2','#B69CFF'),...card(1290,'PREÇO','4.5','#B69CFF')]);
 // Assignment: enlarged single line and precise labels.
 const assign=[R(90,290,1740,370),T('produto = "Suco"',215,360,74,'#EEF4FF',1500,'JetBrains Mono'),T('NOME',215,495,28,'#55D9E8'),T('ATRIBUIÇÃO',540,495,28,'#B69CFF'),T('VALOR (TEXTO)',855,495,28,'#55D9E8'),T('O valor da direita fica associado ao nome da esquerda.',110,740,34,'#A8B8CF')];
 const left=cue('À esquerda'),right=cue('À direita'),eq=cue('O sinal de igual');
 segment(1,s[1],left,assign);segment(1,left,right,[...assign,cursor(260,435)]);segment(1,right,eq,[...assign,cursor(930,435)]);segment(1,eq,s[2],[...assign,cursor(580,435)]);
 const code=['produto = "Suco"','quantidade = 2','preco = 4.5'];
 const n=cue('Quantidade está associada'),decimal=cue('Preco está associado'),until=cue('Até aqui');
 segment(2,s[2],n,editor(code,'Ainda não executamos.',1,'Texto entre aspas. Números sem aspas.',[455,370]));
 segment(2,n,decimal,editor(code,'Ainda não executamos.',1,'quantidade  >  número inteiro',[445,370]));
 segment(2,decimal,until,editor(code,'Ainda não executamos.',2,'preco  >  número decimal. Em Python, use ponto.',[410,413]));
 segment(2,until,s[3],editor(code,'Nenhum print: nenhuma saída.',-1,'Dar nomes aos dados não os mostra na tela.'));
 const full=[...code,'print(produto)','print(quantidade)','print(preco)'];
 const run=cue('Agora executamos'),out=cue('Aparece Suco');
 segment(3,s[3],run,editor(full,'Qual será a primeira saída?',3,'Faça sua previsão antes de executar.',[460,455]));
 segment(3,run,out,editor(full,'Executando…',3,'Consultando os nomes.',[1705,294]));
 segment(3,out,s[4],editor(full,'Suco\n2\n4.5',-1,'O código fica em cima. O resultado, embaixo.'));
 const compare=['produto = "Suco"','print("produto")','print(produto)'];const r5=cue('Execute e observe'),c5=cue('Com aspas',s[4]),n5=cue('Sem aspas',s[4]);
 segment(4,s[4],r5,editor(compare,'Observe a diferença entre as duas linhas.',1,'Aspas indicam um texto literal.',[400,370]));
 segment(4,r5,c5,editor(compare,'produto\nSuco',-1,'Duas instruções parecidas; duas saídas diferentes.',[1705,294]));
 segment(4,c5,n5,editor(compare,'produto\nSuco',1,'print("produto")  >  mostra a palavra produto.',[400,370]));
 segment(4,n5,s[5],editor(compare,'produto\nSuco',2,'print(produto)  >  consulta o valor Suco.',[380,414]));
 const bad=['produto = "Suco"','print(Produto)'];const err=cue('Ao executar',s[5]),hyp=cue('Compare letra por letra'),fix=cue('Vamos mudar apenas'),success=cue('Agora aparece Suco');
 segment(5,s[5],err,editor(bad,'Antes de executar: os nomes são iguais?',1,'Um erro de propósito.',[370,370]));
 segment(5,err,hyp,editor(bad,"NameError: name 'Produto' is not defined.",1,'Leia a linha indicada. Depois, compare os nomes.',[1705,294],true));
 segment(5,hyp,fix,[R(90,290,1740,390),T('produto',180,340,88,'#55D9E8',700,'JetBrains Mono'),T('Produto',1050,340,88,'#FFB4A9',700,'JetBrains Mono'),T('NOME CRIADO',180,505,27,'#A8B8CF'),T('NOME USADO NO PRINT',1050,505,27,'#A8B8CF'),T('p e P são nomes diferentes',500,590,40,'#B69CFF'),T('Hipótese: a primeira letra mudou.',110,750,35),cursor(1065,447)]);
 segment(5,fix,success,editor(['produto = "Suco"','print(produto)'],'Vamos testar a mudança.',1,'Uma alteração: P  >  p.',[370,370]));
 segment(5,success,s[6],editor(['produto = "Suco"','print(produto)'],'Suco',1,'Hipótese  >  mudança pequena  >  novo teste.',[1705,294]));
 const predict=cue('Agora é a sua vez');
 segment(6,s[6],predict,[R(90,290,1740,480),T('01   Nome  >  valor',150,340,50,'#55D9E8'),T('02   print consulta o nome',150,465,50),T('03   Compare a escrita ao investigar erros',150,590,44,'#B69CFF')]);
 segment(6,predict,end,editor(['quantidade = 2','quantidade = 5','print(quantidade)'],'Qual valor será mostrado?',-1,'Volte ao app. Faça sua previsão e teste.'));
 await p.frame(s[3]+3,root+'/frame-code.png');
 await p.frame(hyp+1,root+'/frame-error.png');
 fs.writeFileSync(root+'/timing.json',JSON.stringify({starts:s,duration:end,cues:{run,out,err,hyp,fix,success,predict}},null,2));
};
