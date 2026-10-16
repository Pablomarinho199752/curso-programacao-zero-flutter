import React from 'react';
import {Composition} from 'remotion';
import {Lesson01} from './Lesson01';

export const RemotionRoot: React.FC = () => (
  <Composition
    id="Lesson01"
    component={Lesson01}
    durationInFrames={1621}
    fps={24}
    width={1920}
    height={1080}
  />
);
