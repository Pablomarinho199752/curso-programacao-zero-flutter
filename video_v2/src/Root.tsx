import React from 'react';
import {Composition} from 'remotion';
import {Lesson01} from './Lesson01';
import {Lesson11} from './Lesson11';

export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="Lesson01"
      component={Lesson01}
      durationInFrames={1621}
      fps={24}
      width={1920}
      height={1080}
    />
    <Composition
      id="Lesson11"
      component={Lesson11}
      durationInFrames={1806}
      fps={24}
      width={1920}
      height={1080}
    />
  </>
);
