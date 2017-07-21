/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  NativeModules,
  Button
} from 'react-native';
const IOSSample = NativeModules.IOSSample;
export default class ImageViewApp extends Component {
  render() {
    return (
      <View style={styles.container}>
        <Button
            onPress={() => {IOSSample.showImagePicker(
            (arg)=>{console.log(arg)}
            )}}
            title="Image Picker"
            color="#841584"
            
            />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('ImageViewApp', () => ImageViewApp);
