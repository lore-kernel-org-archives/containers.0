From: Stephan Peijnik <stephan@peijnik.at>
Subject: Re: LSM stacking/secondary modules / RFC: Socket MAC LSM
Date: Thu, 15 Jan 2009 14:57:12 +0100
Message-ID: <1232027832.14136.8.camel@sp-laptop3.sp-local>
References: <1231952352.5315.13.camel@sp-laptop3.sp-local>
	 <1231952313.31192.27.camel@localhost.localdomain>
	 <1231952907.5315.17.camel@sp-laptop3.sp-local>
	 <1231953606.31192.41.camel@localhost.localdomain>
	 <f639a5c10901140934w3a019308yb5c5c1d73b605fd5@mail.gmail.com>
	 <20090114180129.GB7337@kroah.com>
	 <1231972131.5315.48.camel@sp-laptop3.sp-local>
	 <20090114231645.GA24111@kroah.com>
	 <1231979170.5315.69.camel@sp-laptop3.sp-local>
	 <20090115004143.GB14467@us.ibm.com>  <20090115004407.GA14867@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090115004407.GA14867@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Greg KH <greg@kroah.com>, Rafael Konrath <rafael.konrath@gmail.com>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Grzegorz Nosek <root@localdomain.pl>
List-Id: containers.vger.kernel.org

Comments inline.

On Wed, 2009-01-14 at 18:44 -0600, Serge E. Hallyn wrote:
> Quoting Serge E. Hallyn (serue@us.ibm.com):
> > Quoting Stephan Peijnik (stephan@peijnik.at):
> > > On Wed, 2009-01-14 at 15:16 -0800, Greg KH wrote:
> > > > On Wed, Jan 14, 2009 at 11:28:51PM +0100, Stephan Peijnik wrote:
> > > > > But Tuxguardian provides a different set of features and works
> > > > > differently. 
> > > > 
> > > > Not entirely, SELinux provides a lot of what it sounds like Tuxguardian
> > > > provides, but in a different way.  If you were to mix them, it could get
> > > > very messy, very quickly.
> > > 
> > > Well, maybe I don't understand the whole concept behind LSM and/or the
> > > security concept in general. But from my understanding it could, in
> > > theory, be safe to have at least multiple socket MAC modules running. 
> > > If one denies access the others don't need to be consulted. On the other
> > > hand, if all allow a specific call to be made it could be granted.
> > > 
> > > > > Maybe this can't be solved by using the LSM framework, but come up with
> > > > > something different and independent.
> > > > 
> > > > Patches are always welcome.
> > > 
> > > Even though I have no patches prepared I have been playing around with
> > > my ideas.
> > > I haven't done a lot of testing on this yet, as it is meant to be a
> > > prototype only, but two implementations of a possible Socket MAC
> > > subsystem can be found at http://repo.or.cz/w/linux-2.6/sactl.git.
> > > 
> > > The subsystem is intended to be used by modules like Tuxguardian and
> > > does only provide a limited set of information (ie. no direct access to
> > > the relevant socket structures, only works for AF_INET and AF_INET6
> > > sockets).
> > 
> > So do you think we could come up with a usable framework using the
> > idea which Paul Menage suggests here:
> > https://lists.linux-foundation.org/pipermail/containers/2009-January/015280.html
> > ?
> > 
> > Basically, you would use a control group (cgroup) to track tasks.
> > I.e. you might launch firefox in a separate 'webclient' cgroup.
> > Traffic then gets controlled (and mangled) based on the cgroup
> > of the sending/receiving task.

Okay, that idea does sound nice. However, to me it rather looks like
another use-case for the framework/interface I am proposing (ie. sactl).

Using sactl the cgroup-based approach could easily hook the relevant
socket calls. sactl might need some refining for this, but then again
it's just a proposal and not anywhere being a final interface.

So Paul, do you think the interface would be of any use to you? 

On the other hand the cgroup-based approach could provide a similar
interface to the userspace, which would also be an option.

> > Presumably one possible iptables target would be something which
> > launches a popup window to ask the user 'should task firefox in
> > cgroup webclient be allowed to access google.com'?

If such a target is implemented it could also be done this way. To be
honest I am not really sure about which road to take myself.

-- Stephan

