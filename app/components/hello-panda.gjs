import { css } from 'ember-pandacss-demo/styled-system/css';

const style = css({
  fontSize: '4xl',
  fontWeight: 'bold',
  color: 'blue.400',
});

<template>
  <div class={{style}}>Hello 🐼!</div>
</template>
