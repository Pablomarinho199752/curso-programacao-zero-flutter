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
      <div
        key={`h-${i}`}
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          top: i * 64,
          height: 1,
          background: 'rgba(90,180,255,.08)',
        }}
      />
    ))}
    {Array.from({length: 30}).map((_, i) => (
      <div
        key={`v-${i}`}
        style={{
          position: 'absolute',
          top: 0,
          bottom: 0,
          left: i * 72,
          width: 1,
          background: 'rgba(90,180,255,.05)',
        }}
      />
    ))}
  </AbsoluteFill>
);

const Presenter: React.FC<{
  x?: number;
  y?: number;
  scale?: number;
  talk?: number;
  wave?: number;
}> = ({x = 1320, y = 530, scale = 1, talk = 0, wave = 0}) => {
  const bob = Math.sin(wave * 0.08) * 10;
  return (
    <div
      style={{
        position: 'absolute',
        left: x,
        top: y + bob,
        transform: `translate(-50%,-50%) scale(${scale})`,
        width: 430,
        height: 560,
      }}
    >
      <div
        style={{
          position: 'absolute',
          left: 72,
          top: 170,
          width: 290,
          height: 330,
          borderRadius: '48% 48% 16% 16%',
          background: 'linear-gradient(160deg,#233d75,#17264d)',
          boxShadow: '0 25px 80px rgba(0,0,0,.35)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 120,
          top: 45,
          width: 200,
          height: 220,
          borderRadius: '50%',
          background: '#ffd9c5',
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 100,
          top: 15,
          width: 245,
          height: 170,
          borderRadius: '55% 55% 45% 45%',
          background: '#261c40',
          transform: 'rotate(-3deg)',
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 116,
          top: 55,
          width: 190,
          height: 58,
          background: '#261c40',
          clipPath:
            'polygon(0 0,100% 0,82% 52%,65% 25%,48% 78%,31% 28%,0 70%)',
        }}
      />
      {[154, 258].map((left) => (
        <div
          key={left}
          style={{
            position: 'absolute',
            left,
            top: 137,
            width: 26,
            height: 18,
            borderRadius: '50%',
            background: '#fff',
          }}
        >
          <div
            style={{
              width: 11,
              height: 15,
              borderRadius: '50%',
              background: '#54b8ff',
              margin: '2px auto',
            }}
          />
        </div>
      ))}
      <div
        style={{
          position: 'absolute',
          left: 203,
          top: 187,
          width: 34,
          height: Math.max(4, 8 + talk * 24),
          borderRadius: '0 0 20px 20px',
          background: '#9e3d56',
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 65,
          top: 205,
          width: 75,
          height: 160,
          borderRadius: 40,
          background: '#233d75',
          transform: `rotate(${18 - Math.sin(wave * 0.1) * 10}deg)`,
          transformOrigin: 'top center',
        }}
      />
      <div
        style={{
          position: 'absolute',
          right: 66,
          top: 210,
          width: 75,
          height: 160,
          borderRadius: 40,
          background: '#233d75',
          transform: `rotate(${-18 + Math.sin(wave * 0.1 + 1) * 12}deg)`,
          transformOrigin: 'top center',
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 85,
          top: 31,
          width: 26,
          height: 185,
          borderRadius: 20,
          background: C.cyan,
          opacity: 0.9,
        }}
      />
      <div
        style={{
          position: 'absolute',
          right: 86,
          top: 31,
          width: 26,
          height: 185,
          borderRadius: 20,
          background: C.cyan,
          opacity: 0.9,
        }}
      />
    </div>
  );
};

const Tag: React.FC<{children: React.ReactNode}> = ({children}) => (
  <div
    style={{
      display: 'inline-block',
      padding: '10px 18px',
      borderRadius: 999,
      background: 'rgba(82,214,255,.12)',
      border: '1px solid rgba(82,214,255,.35)',
      color: C.cyan,
      fontSize: 28,
      fontWeight: 700,
      letterSpacing: 1,
    }}
  >
    {children}
  </div>
);

const Caption: React.FC<{title: string; body?: string}> = ({title, body}) => (
  <div
    style={{
      position: 'absolute',
      left: 110,
      right: 110,
      bottom: 70,
      padding: '24px 32px',
      borderRadius: 24,
      background: 'rgba(5,10,22,.82)',
      border: '1px solid rgba(255,255,255,.12)',
    }}
  >
    <div style={{fontSize: 38, fontWeight: 800, color: C.white}}>{title}</div>
    {body && (
      <div style={{fontSize: 28, color: C.soft, marginTop: 8}}>{body}</div>
    )}
  </div>
);

const CodeBox: React.FC<{frame: number}> = ({frame}) => {
  const reveal = Math.floor(
    interpolate(frame, [560, 760], [0, 2], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    }),
  );
  const lines = ['print("Olá, mundo!")', 'print("Um passo de cada vez")'];
  return (
    <div
      style={{
        position: 'absolute',
        left: 180,
        top: 190,
        width: 1060,
        height: 590,
        borderRadius: 28,
        background: '#06111f',
        border: '1px solid #21456c',
        boxShadow: '0 30px 90px rgba(0,0,0,.4)',
        overflow: 'hidden',
      }}
    >
      <div
        style={{
          height: 64,
          background: '#0d223b',
          display: 'flex',
          alignItems: 'center',
          padding: '0 24px',
          gap: 10,
        }}
      >
        {['#ff6b6b', '#ffd166', '#62e8a8'].map((c) => (
          <span
            key={c}
            style={{width: 16, height: 16, borderRadius: '50%', background: c}}
          />
        ))}
        <span style={{marginLeft: 20, color: '#9bc4df', fontSize: 24}}>
          primeiro_programa.py
        </span>
      </div>
      <div
        style={{
          padding: 52,
          fontFamily: 'monospace',
          fontSize: 42,
          lineHeight: 1.8,
          color: '#dff7ff',
        }}
      >
        {lines.map((line, i) => (
          <div key={line} style={{opacity: i < reveal + 1 ? 1 : 0.12}}>
            <span style={{color: '#6e87a4', marginRight: 24}}>{i + 1}</span>
            {line}
          </div>
        ))}
      </div>
    </div>
  );
};

const Flow: React.FC<{frame: number}> = ({frame}) => {
  const labels = ['PREVER', 'EXECUTAR', 'COMPARAR', 'CORRIGIR'];
  return (
    <div
      style={{
        position: 'absolute',
        left: 150,
        right: 150,
        top: 290,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
      }}
    >
      {labels.map((label, i) => {
        const a = spring({
          frame: frame - 940 - i * 12,
          fps: 24,
          config: {damping: 15},
        });
        return (
          <React.Fragment key={label}>
            <div
              style={{
                width: 300,
                height: 190,
                borderRadius: 32,
                display: 'grid',
                placeItems: 'center',
                background:
                  'linear-gradient(145deg,rgba(82,214,255,.18),rgba(141,107,255,.15))',
                border: '1px solid rgba(120,210,255,.3)',
                transform: `scale(${0.7 + 0.3 * a})`,
                opacity: a,
              }}
            >
              <div style={{fontSize: 34, fontWeight: 900}}>{label}</div>
            </div>
            {i < 3 && <div style={{fontSize: 48, color: C.cyan}}>→</div>}
          </React.Fragment>
        );
      })}
    </div>
  );
};

export const Lesson01: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const sec = frame / fps;
  const fade = (start: number, end: number) =>
    interpolate(sec, [start, start + 0.5, end - 0.5, end], [0, 1, 1, 0], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    });
  const talk = 0.5 + 0.5 * Math.sin(frame * 0.32);

  return (
    <AbsoluteFill style={{fontFamily: 'Arial, Helvetica, sans-serif', color: C.white}}>
      <Grid />
      <Audio src={staticFile('voice.wav')} />

      {sec < 12 && (
        <div style={{opacity: fade(0, 12)}}>
          <div style={{position: 'absolute', left: 120, top: 170, width: 980}}>
            <Tag>MÓDULO 0 · AULA 0.1</Tag>
            <div style={{fontSize: 78, fontWeight: 950, lineHeight: 1.05, marginTop: 28}}>
              Programar não é
              <br />
              <span style={{color: C.cyan}}>decorar comandos.</span>
            </div>
            <div style={{fontSize: 34, color: C.soft, marginTop: 30, maxWidth: 880}}>
              É transformar uma ideia em passos claros e testáveis.
            </div>
          </div>
          <Presenter talk={talk} wave={frame} />
          <Caption
            title="Comece pelo raciocínio"
            body="A linguagem vem depois: primeiro entendemos o problema."
          />
        </div>
      )}

      {sec >= 12 && sec < 25 && (
        <div style={{opacity: fade(12, 25)}}>
          <div style={{position: 'absolute', left: 120, top: 120}}>
            <Tag>ALGORITMO</Tag>
            <div style={{fontSize: 62, fontWeight: 900, marginTop: 24}}>
              Um robô não adivinha.
            </div>
            <div style={{fontSize: 32, color: C.soft, marginTop: 16, width: 760}}>
              Ele precisa saber o que fazer, em qual ordem e quando parar.
            </div>
          </div>
          <div
            style={{
              position: 'absolute',
              left: 210,
              top: 420,
              width: 430,
              height: 350,
              borderRadius: 46,
              background: 'linear-gradient(145deg,#17345a,#0b203b)',
              border: '1px solid #2d5f89',
              display: 'grid',
              placeItems: 'center',
              fontSize: 145,
            }}
          >
            🤖
          </div>
          <div style={{position: 'absolute', left: 760, top: 400, width: 900, display: 'grid', gap: 22}}>
            {[
              '1. Identifique a tarefa',
              '2. Quebre em passos',
              '3. Coloque na ordem',
              '4. Defina quando termina',
            ].map((x, i) => (
              <div
                key={x}
                style={{
                  padding: '20px 26px',
                  borderRadius: 18,
                  background: 'rgba(255,255,255,.06)',
                  border: '1px solid rgba(255,255,255,.09)',
                  fontSize: 30,
                  transform: `translateX(${Math.max(0, 80 - (frame - 300 - i * 12) * 4)}px)`,
                }}
              >
                {x}
              </div>
            ))}
          </div>
          <Caption
            title="Algoritmo = sequência de passos"
            body="Código é esse plano escrito em uma linguagem que o computador entende."
          />
        </div>
      )}

      {sec >= 25 && sec < 40 && (
        <div style={{opacity: fade(25, 40)}}>
          <CodeBox frame={frame} />
          <Presenter x={1530} y={600} scale={0.78} talk={talk} wave={frame} />
          <Caption
            title={'print("Olá, mundo!")'}
            body="As aspas delimitam o texto. O que aparece na saída é Olá, mundo!, sem as aspas."
          />
        </div>
      )}

      {sec >= 40 && sec < 56 && (
        <div style={{opacity: fade(40, 56)}}>
          <div style={{position: 'absolute', left: 120, top: 120}}>
            <Tag>MÉTODO DO CURSO</Tag>
            <div style={{fontSize: 62, fontWeight: 900, marginTop: 24}}>
              Você aprende testando.
            </div>
          </div>
          <Flow frame={frame} />
          <Caption
            title="Prever → executar → comparar → corrigir"
            body="Se algo der errado, altere uma coisa de cada vez e observe o resultado."
          />
        </div>
      )}

      {sec >= 56 && (
        <div style={{opacity: fade(56, 67.5)}}>
          <div style={{position: 'absolute', left: 120, top: 110}}>
            <Tag>MINI PROJETO</Tag>
            <div style={{fontSize: 62, fontWeight: 900, marginTop: 24}}>
              Seu primeiro cartão de apresentação
            </div>
            <div style={{fontSize: 32, color: C.soft, marginTop: 14}}>
              Duas linhas. Dois textos seus. Uma primeira vitória.
            </div>
          </div>
          <div
            style={{
              position: 'absolute',
              left: 170,
              top: 360,
              width: 980,
              padding: 44,
              borderRadius: 30,
              background: '#06111f',
              border: '1px solid #21456c',
              fontFamily: 'monospace',
              fontSize: 38,
              lineHeight: 1.8,
            }}
          >
            <div>print("Meu apelido")</div>
            <div>print("Quero criar...")</div>
          </div>
          <Presenter x={1535} y={620} scale={0.85} talk={talk} wave={frame} />
          <Caption
            title="Um passo de cada vez"
            body="O objetivo é entender por que funciona — não apenas copiar até funcionar."
          />
        </div>
      )}
    </AbsoluteFill>
  );
};
