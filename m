From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Device Namespaces
Date: Mon, 30 Sep 2013 09:33:26 -0700
Message-ID: <1380558806.2161.18.camel@dabdike.int.hansenpartnership.com>
References: <871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
	<87bo3gshz5.fsf_-_@xmission.com> <20130926053320.GB3725@kroah.com>
	<CAE=NcrbPXGWU8FUgwchXyL5HjXf+4AKbgUWGe1ZO=Xcq=iV-Lg@mail.gmail.com>
	<20130926135604.GA16624@kroah.com>
	<CAE=NcrY3xC1AF_GV2b1KsF7AwYZTuGBuKLS5yBUWoWcmKU4YBg@mail.gmail.com>
	<20130926170757.GA9345@kroah.com>
	<1380555439.2161.5.camel@dabdike.int.hansenpartnership.com>
	<20130930161117.GA26459@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130930161117.GA26459-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, mhw <mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, devel <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2013-09-30 at 09:11 -0700, Greg Kroah-Hartman wrote:
> On Mon, Sep 30, 2013 at 08:37:19AM -0700, James Bottomley wrote:
> > On Thu, 2013-09-26 at 10:07 -0700, Greg Kroah-Hartman wrote:
> > > On Thu, Sep 26, 2013 at 08:01:31PM +0300, Janne Karhunen wrote:
> > > > That being said, our wish would be to support any combination of
> > > > OS's and frankly, I'd be slightly annoyed to tell the customer that
> > > > they can't do two Androids or we magically run out of bits.
> > > 
> > > If you want to support "any" combination of operating systems, then use
> > > a hypervisor, that's what they are there for :)
> > 
> > No that's not quite the right way to think about it: The correct
> > statement is only use a hypervisor if you need different kernels.  With
> > Windows, it happens to be true that you need a different kernel for each
> > different OS version.  However; with Linux, thanks to strong ABI
> > backwards compatibility, you mostly don't.  The way OpenVZ works today
> > is that it installs a modified kernel which can then bring up every
> > Linux OS in a separate container.  Our use case is the hosters that give
> > you root login to a virtual private server and allow you to upgrade it
> > on your own.  The reason for using a container rather than a hypervisor
> > is the old density and elasticity one:  3x the density (i.e. 1/3 the
> > overhead cost to the hoster) and the boot only needs to start at init,
> > not bring up of virtual hardware and booting a second kernel.
> 
> I understand that some people really like the idea of using OpenVZ for
> various things like this, but to claim that because of it we need to
> hack up the driver core in the kernel into unimaginable pieces is not
> necessarily something that I'll agree with.

I don't believe I claimed that.  In fact, from 3.9 we can already bring
up an OpenVZ containerised system running different versions of Linux
that you can give someone root access to with no kernel modifications
whatsoever.  The user space solution currently works for us because
we're handing out server VPSs, so the device configuration is fixed as
we init the container.  However, we do have use cases for dynamic
instead of static device configurations, which is why we're
participating in the debate.

> But all of this is just words, I have yet to see any patches for any of
> this, so I'll just wait until that happens before worrying about it...

Well, that's because we're still debating what the best approach is.  If
you want a historical parallel: the comments you make above (hack up
the ... kernel into unimaginable pieces) is an almost exact mirror of
the comments that were made rejecting the in-kernel Checkpoint/Restore
patches at the 2010 Kernel Summit ... yet we have it fully functional
today in a form that proved acceptable.

James
