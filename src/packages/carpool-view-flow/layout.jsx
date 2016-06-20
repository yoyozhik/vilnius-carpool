import React from 'react'
import { muiTheme } from './react/config'
import ThemeManager from 'material-ui/lib/styles/theme-manager'
import { createContainer } from 'meteor/react-meteor-data'
import Loader from './react/components/Loader'
import FloatingNewRideButton from './react/layout/NewRideButton'
import FloatingFeedbackButton from './react/layout/FloatingFeedbackButton.jsx'
import { Paper } from 'material-ui'

export class MainLayout extends React.Component {
  constructor (props) {
    super(props)

    const resizeListener = () => {
      const ww = window.innerWidth
      const wh = window.innerHeight
      this.setState({
        ww: ww,
        wh: wh,
        appWidth: ww > 1024 ? 900 : ww,
        appHeight: wh,
        isMobile: ww <= 1024,
      })
    }

    window.addEventListener('resize', resizeListener)
    window.addEventListener('orientationchange', resizeListener)

    const ww = window.innerWidth
    const wh = window.innerHeight
    this.state = {
      ww: window.innerWidth,
      wh: window.innerHeight,
      appWidth: ww > 1024 ? 900 : ww,
      appHeight: ww <= 1024 ? wh : wh - 30,
      isMobile: ww <= 1024,
      resizeListener,
    }
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.state.resizeListener)
    window.removeEventListener('orientationchange', this.state.resizeListener)
  }

  getChildContext () {
    return {
      muiTheme: ThemeManager.getMuiTheme(muiTheme),
    }
  }

  renderElement(element, extraParams = {}) {
    return !element ? null :
      React.cloneElement(element, {
        width: this.state.appWidth,
        isMobile: this.state.isMobile,
        ...extraParams,
      })
  }

  renderMobile () {
    const topMenuHeight = this.props.topMenu ? 50 : 0
    const topSearchHeight = this.props.topSearch ? 115 : 0
    const topFilterHeight = this.props.topFilter ? 48 : 0 // Looks bad if not 48 at the moment
    const bottomMenuHeight = this.props.bottomMenu ? 64 : 0
    const contentHeight = this.state.appHeight - (topMenuHeight + topSearchHeight + topFilterHeight + bottomMenuHeight)

    const iconSideOffset = (this.state.ww - this.state.appWidth) / 2

    return (
      <div>
        {this.props.topMenu || this.props.topFilter || this.props.topSearch ? (
          <header>
            <Paper>
              {this.renderElement(this.props.topMenu, { height: topMenuHeight })}
              {this.renderElement(this.props.topFilter, { height: topFilterHeight })}
              {this.renderElement(this.props.topSearch, { height: topSearchHeight })}
            </Paper>
          </header>
        ) : null}
        <main>
          {this.renderElement(this.props.content, { height: contentHeight })}
        </main>
        {this.props.bottomMenu ? (
          <bottom>
            {this.renderElement(this.props.bottomMenu, { height: bottomMenuHeight })}
          </bottom>
        ) : null}
        {this.props.renderNewTripButton ? <FloatingNewRideButton isMobile={this.state.isMobile} sideOffset={iconSideOffset} /> : null}
        {this.props.renderFeedbackButton ? <FloatingFeedbackButton isMobile={this.state.isMobile} sideOffset={iconSideOffset} /> : null}
      </div>
    )
  }

  render () {
    if (this.state.isMobile) {
      return this.renderMobile()
    }

    return (
      <Paper
        style={{
          width:this.state.appWidth,
          height: this.state.appHeight,
          margin: '10px auto',
        }}
      >
        {this.renderMobile()}
      </Paper>
    )
    // Needs to render <= 1024, >1024, >1280
  }
}

MainLayout.childContextTypes = {
  muiTheme: React.PropTypes.object,
}

MainLayout.propTypes = {
  topMenu: React.PropTypes.element,
  topFilter: React.PropTypes.element,
  topSearch: React.PropTypes.element,
  bottomMenu: React.PropTypes.element,
  content: React.PropTypes.element.isRequired,
}


// const Wrapper = React.createClass({
//   getInitialState () {
//     const resizeListener = () => {
//       this.setState({
//         ww: window.innerWidth,
//         wh: window.innerHeight
//       })
//     }
//
//     window.addEventListener('resize', resizeListener)
//
//     return {
//       ww: window.innerWidth,
//       wh: window.innerHeight,
//       resizeListener,
//     }
//   },
//
//   componentWillUnmount () {
//     window.removeEventListener('resize', this.state.resizeListener)
//   },
//
//   childContextTypes: {
//     muiTheme: React.PropTypes.object,
//     appWidth: React.PropTypes.number,
//     appHeight: React.PropTypes.number,
//     isMobile: React.PropTypes.bool,
//   },
//
//   getChildContext () {
//     return {
//       muiTheme: ThemeManager.getMuiTheme(muiTheme),
//       appWidth: this.state.ww > 1300 ? 1300 : this.state.ww,
//       appHeight: this.state.wh,
//       isMobile: this.state.ww <= 1300,
//     }
//   },
//
//   render () {
//     return this.state.ww <= 1300 ? this.props.children : (
//       <Paper style={{
//         width: 1300,
//         padding: 20,
//         margin: '0px auto',
//       }}>
//         {this.props.children}
//       </Paper>
//     )
//   }
// })
//
// // This layout makes sure that at least users subscribtion is loadded
// // TODO apply this only for login
// export const PlainLayout = createContainer(({topMenu, content}) => {
//   isLoading = !userSubs.ready();
//   return {isLoading, topMenu, content};
// }, ({isLoading, topMenu, content}) => {
//   const topBarHeight = 45
//
//   if(isLoading) {
//     return (
//       <section style={{height: "100%", marginTop: 25}}>
//         <Loader />
//       </section>
//     )
//   } else {
//     return (
//       <Wrapper>
//         <div>
//           <header>
//             {topMenu}
//           </header>
//           <main style={{marginTop: topBarHeight }}>
//             {content}
//           </main>
//         </div>
//       </Wrapper>
//     )
//   }
// });
