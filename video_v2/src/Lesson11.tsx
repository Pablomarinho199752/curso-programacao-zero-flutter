import React from 'react';
import {
  AbsoluteFill,
  Audio,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';

const C = {
  bg: '#071224',
  cyan: '#52d6ff',
  purple: '#8d6bff',
  white: '#f7fbff',
  soft: '#bcd5ea',
  green: '#62e8a8',
  red: '#ff7a8f',
  yellow: '#ffd166',
};

const Grid: React.FC = () => (
  <AbsoluteFill
    style={{
      background:
        `radial-gradient(circle at 78% 20%, #203764 0, ${C.bg} 46%), linear-gradient(135deg,#071224,#0c1830)`,
      overflow: 'hidden',
    }}
  >
    {Array.from({length: 18}).map((_, i) => (
      <div key={`h-${i}`} style={{position:'absolute',left:0,right:0,top:i*64,height:1,background:'rgba(90,180,255,.08)'}} />
    ))}
    {Array.from({length: 30}).map((_, i) => (
      <div key={`v-${i}`} style={{position:'absolute',top:0,bottom:0,left:i*72,width:1,background:'rgba(90,180,255,.05)'}} />
    ))}
  </AbsoluteFill>
);

const Tag: React.FC<{children: React.ReactNode}> = ({children}) => (
  <div style={{display:'inline-block',padding:'10px 18px',borderRadius:999,background:'rgba(82,214,255,.12)',border:'1px solid rgba(82,214,255,.35)',color:C.cyan,fontSize:28,fontWeight:700,letterSpacing:1}}>
    {children}
  </div>
);

const Caption: React.FC<{title:string;body?:string}> = ({title,body}) => (
  <div style={{position:'absolute',left:110,right:110,bottom:70,padding:'24px 32px',borderRadius:24,background:'rgba(5,10,22,.84)',border:'1px solid rgba(255,255,255,.12)'}}>
    <div style={{fontSize:38,fontWeight:800,color:C.white}}>{title}</div>
    {body && <div style={{fontSize:28,color:C.soft,marginTop:8}}>{body}</div>}
  </div>
);

const Presenter: React.FC<{x?:number;y?:number;scale?:number;talk?:number;frame:number}> = ({x=1430,y=520,scale=1,talk=0,frame}) => {
  const bob = Math.sin(frame*0.07)*10;
  const hand = Math.sin(frame*0.11)*13;
  return <div style={{position:'absolute',left:x,top:y+bob,transform:`translate(-50%,-50%) scale(${scale})`,width:430,height:560}}>
    <div style={{position:'absolute',left:72,top:170,width:290,height:330,borderRadius:'48% 48% 16% 16%',background:'linear-gradient(160deg,#233d75,#17264d)',boxShadow:'0 25px 80px rgba(0,0,0,.35)'}} />
    <div style={{position:'absolute',left:120,top:45,width:200,height:220,borderRadius:'50%',background:'#ffd9c5'}} />
    <div style={{position:'absolute',left:100,top:15,width:245,height:170,borderRadius:'55% 55% 45% 45%',background:'#261c40',transform:'rotate(-3deg)'}} />
    <div style={{position:'absolute',left:116,top:55,width:190,height:58,background:'#261c40',clipPath:'polygon(0 0,100% 0,82% 52%,65% 25%,48% 78%,31% 28%,0 70%)'}} />
    {[154,258].map((left)=><div key={left} style={{position:'absolute',left,top:137,width:26,height:18,borderRadius:'50%',background:'#fff'}}><div style={{width:11,height:15,borderRadius:'50%',background:'#54b8ff',margin:'2px auto'}} /></div>)}
    <div style={{position:'absolute',left:203,top:187,width:34,height:Math.max(4,8+talk*24),borderRadius:'0 0 20px 20px',background:'#9e3d56'}} />
    <div style={{position:'absolute',left:65,top:205,width:75,height:160,borderRadius:40,background:'#233d75',transform:`rotate(${18-hand}deg)`,transformOrigin:'top center'}} />
    <div style={{position:'absolute',right:66,top:210,width:75,height:160,borderRadius:40,background:'#233d75',transform:`rotate(${-18+hand}deg)`,transformOrigin:'top center'}} />
    <div style={{position:'absolute',left:85,top:31,width:26,height:185,borderRadius:20,background:C.cyan,opacity:.9}} />
    <div style={{position:'absolute',right:86,top:31,width:26,height:185,borderRadius:20,background:C.cyan,opacity:.9}} />
  </div>;
};

const DataBox: React.FC<{label:string;value:string;color:string;progress:number;x:number}> = ({label,value,color,progress,x}) => (
  <div style={{position:'absolute',left:x,top:365,width:350,height:260,borderRadius:34,background:'linear-gradient(145deg,rgba(255,255,255,.08),rgba(255,255,255,.03))',border:`2px solid ${color}55`,boxShadow:`0 20px 80px ${color}22`,transform:`translateY(${(1-progress)*90}px) scale(${.84+.16*progress})`,opacity:progress,padding:30}}>
    <div style={{fontSize:22,color:C.soft,letterSpacing:1.5}}>VARIÁVEL</div>
    <div style={{fontSize:42,fontWeight:900,color,marginTop:12}}>{label}</div>
    <div style={{marginTop:28,height:92,borderRadius:22,display:'grid',placeItems:'center',background:'#06111f',fontSize:34,fontFamily:'monospace',color:C.white}}>{value}</div>
  </div>
);

const CodeBox: React.FC<{frame:number}> = ({frame}) => {
  const lines = [
    'apelido = "Pythonista"',
    'projetos = 2',
    'meta = 7.5',
    'print(apelido)',
    'print(projetos)',
    'print(meta)',
  ];
  return <div style={{position:'absolute',left:135,top:165,width:1180,height:675,borderRadius:28,background:'#06111f',border:'1px solid #21456c',boxShadow:'0 30px 90px rgba(0,0,0,.4)',overflow:'hidden'}}>
    <div style={{height:64,background:'#0d223b',display:'flex',alignItems:'center',padding:'0 24px',gap:10}}>
      {['#ff6b6b','#ffd166','#62e8a8'].map(c=><span key={c} style={{width:16,height:16,borderRadius:'50%',background:c}} />)}
      <span style={{marginLeft:20,color:'#9bc4df',fontSize:24}}>variaveis.py</span>
    </div>
    <div style={{padding:42,fontFamily:'monospace',fontSize:36,lineHeight:1.65,color:'#dff7ff'}}>
      {lines.map((line,i)=>{
        const p = spring({frame:frame-600-i*14,fps:24,config:{damping:16}});
        return <div key={line} style={{opacity:.12+.88*p,transform:`translateX(${(1-p)*70}px)`}}><span style={{color:'#6e87a4',marginRight:22}}>{i+1}</span>{line}</div>;
      })}
    </div>
  </div>;
};

const Assignment: React.FC<{frame:number}> = ({frame}) => {
  const p = spring({frame:frame-335,fps:24,config:{damping:14}});
  return <div style={{position:'absolute',left:180,right:180,top:300,height:420}}>
    <div style={{position:'absolute',left:0,top:120,width:420,height:170,borderRadius:30,display:'grid',placeItems:'center',background:'rgba(82,214,255,.12)',border:'1px solid rgba(82,214,255,.35)',fontFamily:'monospace',fontSize:44,color:C.cyan}}>projetos</div>
    <div style={{position:'absolute',left:640,top:120,width:420,height:170,borderRadius:30,display:'grid',placeItems:'center',background:'rgba(141,107,255,.14)',border:'1px solid rgba(141,107,255,.35)',fontFamily:'monospace',fontSize:50,color:C.white}}>2</div>
    <div style={{position:'absolute',left:410,top:150,fontSize:90,color:C.yellow,transform:`scale(${.7+.3*p})`}}>=</div>
    <div style={{position:'absolute',left:250,top:20,fontSize:30,color:C.soft}}>nome</div>
    <div style={{position:'absolute',right:290,top:20,fontSize:30,color:C.soft}}>valor</div>
    <div style={{position:'absolute',left:455,top:335,fontSize:30,color:C.green,opacity:p}}>atribuição → guarda o valor usando esse nome</div>
  </div>;
};

const ErrorScene: React.FC<{frame:number}> = ({frame}) => {
  const shake = Math.sin(frame*.75)*6;
  return <div>
    <div style={{position:'absolute',left:170,top:220,width:980,height:470,borderRadius:30,background:'#06111f',border:'1px solid #3e2540',padding:48,fontFamily:'monospace',fontSize:43,lineHeight:1.9}}>
      <div><span style={{color:C.green}}>1</span> nome = <span style={{color:C.yellow}}>&quot;Pablo&quot;</span></div>
      <div style={{transform:`translateX(${shake}px)`}}><span style={{color:C.green}}>2</span> print(<span style={{color:C.red}}>nom</span>)</div>
      <div style={{marginTop:42,padding:24,borderRadius:18,background:'rgba(255,122,143,.10)',border:'1px solid rgba(255,122,143,.35)',color:C.red,fontSize:30}}>NameError: nom não foi definido</div>
    </div>
    <Presenter x={1510} y={590} scale={.72} talk={.7} frame={frame} />
  </div>;
};

export const Lesson11: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const sec = frame/fps;
  const fade = (start:number,end:number) => interpolate(sec,[start,start+.5,end-.5,end],[0,1,1,0],{extrapolateLeft:'clamp',extrapolateRight:'clamp'});
  const talk = .5+.5*Math.sin(frame*.31);

  return <AbsoluteFill style={{fontFamily:'Arial, Helvetica, sans-serif',color:C.white}}>
    <Grid />
    <Audio src={staticFile('voice_1_1.wav')} />

    {sec < 13 && <div style={{opacity:fade(0,13)}}>
      <div style={{position:'absolute',left:120,top:150,width:980}}>
        <Tag>MÓDULO 1 · AULA 1.1</Tag>
        <div style={{fontSize:76,fontWeight:950,lineHeight:1.05,marginTop:28}}>Variáveis dão<br/><span style={{color:C.cyan}}>nome aos dados.</span></div>
        <div style={{fontSize:34,color:C.soft,marginTop:30,maxWidth:880}}>Pense em uma caixa: etiqueta por fora, valor por dentro.</div>
      </div>
      <Presenter talk={talk} frame={frame} />
      <Caption title="Nome ≠ valor" body="A variável é o nome usado para acessar uma informação." />
    </div>}

    {sec >= 13 && sec < 27 && <div style={{opacity:fade(13,27)}}>
      <div style={{position:'absolute',left:120,top:105}}><Tag>TRÊS TIPOS DE VALOR</Tag><div style={{fontSize:58,fontWeight:900,marginTop:22}}>A mesma ideia serve para dados diferentes.</div></div>
      <DataBox label="apelido" value={'"Pythonista"'} color={C.cyan} progress={spring({frame:frame-325,fps,config:{damping:14}})} x={150} />
      <DataBox label="projetos" value={'2'} color={C.green} progress={spring({frame:frame-345,fps,config:{damping:14}})} x={580} />
      <DataBox label="meta" value={'7.5'} color={C.purple} progress={spring({frame:frame-365,fps,config:{damping:14}})} x={1010} />
      <Caption title="Texto, inteiro e decimal" body="O nome pode apontar para diferentes tipos de valor." />
    </div>}

    {sec >= 27 && sec < 40 && <div style={{opacity:fade(27,40)}}>
      <div style={{position:'absolute',left:120,top:110}}><Tag>ATRIBUIÇÃO</Tag><div style={{fontSize:58,fontWeight:900,marginTop:20}}>O sinal = guarda um valor.</div></div>
      <Assignment frame={frame} />
      <Caption title="Leia da direita para a esquerda" body="Pegue o valor da direita e associe ao nome da esquerda." />
    </div>}

    {sec >= 40 && sec < 55 && <div style={{opacity:fade(40,55)}}>
      <CodeBox frame={frame} />
      <Presenter x={1550} y={590} scale={.70} talk={talk} frame={frame} />
      <Caption title="print(nome_da_variável)" body="O Python procura o valor guardado e mostra esse valor na saída." />
    </div>}

    {sec >= 55 && sec < 66 && <div style={{opacity:fade(55,66)}}>
      <div style={{position:'absolute',left:120,top:105}}><Tag>ERRO COMUM</Tag><div style={{fontSize:58,fontWeight:900,marginTop:20}}>nome e nom são diferentes.</div></div>
      <ErrorScene frame={frame} />
      <Caption title="Confira letra por letra" body="Antes de mudar tudo, compare o nome criado com o nome usado." />
    </div>}

    {sec >= 66 && <div style={{opacity:fade(66,75.23)}}>
      <div style={{position:'absolute',left:130,top:130,width:1100}}><Tag>MINI PROJETO</Tag><div style={{fontSize:64,fontWeight:950,marginTop:24}}>Monte uma ficha de projeto.</div><div style={{fontSize:30,color:C.soft,marginTop:14}}>Um texto, um inteiro e um decimal — com nomes escolhidos por você.</div></div>
      <div style={{position:'absolute',left:180,top:390,width:980,height:360,borderRadius:28,background:'#06111f',border:'1px solid #21456c',padding:44,fontFamily:'monospace',fontSize:36,lineHeight:1.8}}>
        <div><span style={{color:C.cyan}}>projeto</span> = <span style={{color:C.yellow}}>&quot;Meu app&quot;</span></div>
        <div><span style={{color:C.cyan}}>tarefas</span> = <span style={{color:C.green}}>3</span></div>
        <div><span style={{color:C.cyan}}>versao</span> = <span style={{color:C.purple}}>1.0</span></div>
        <div style={{marginTop:14,color:C.soft}}>print(projeto) · print(tarefas) · print(versao)</div>
      </div>
      <Presenter x={1510} y={580} scale={.75} talk={talk} frame={frame} />
      <Caption title="Use nomes que façam sentido" body="O objetivo é entender o dado, não apenas copiar o exemplo." />
    </div>}
  </AbsoluteFill>;
};
