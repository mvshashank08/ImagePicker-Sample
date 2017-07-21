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
  Button,
  Platform
} from 'react-native';

export default class ImageViewApp extends Component {
  constructor(props){
    super(props);
    this.state = {
      text: "Yet to be received"
    }
    this.buttonHandler = this.buttonHandler.bind(this);
  }
  buttonHandler(){
    if(Platform.OS === 'ios'){}
    else{
      NativeModules.ImagePicker.openSelectDialog(
        {}, // no config yet
        (uri) => { console.log("URI: "+uri); this.setState({text: uri}) },
        (error) => { console.log("Error: "+error) }
      );
    }
    
  }
  render() {
    return (
      <View style={styles.container}>
        <Button
          onPress={this.buttonHandler}
          title="Open Gallery"
          color="#841584"
        />
        <Text>{this.state.text}</Text>
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
