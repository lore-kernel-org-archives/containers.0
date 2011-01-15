From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 4/7] allow killing tasks in your own or child userns
Date: Sat, 15 Jan 2011 08:12:20 -0600
Message-ID: <20110115141220.GA2252__28610.1226731718$1295100797$gmane$org@localhost>
References: <20110110211135.GA22446@mail.hallyn.com>
	<20110110211334.GD22564@mail.hallyn.com>
	<20110110215240.GA21351@wavehammer.waldi.eu.org>
	<20110110225151.GA18944@localhost>
	<20110110232335.GA27029@wavehammer.waldi.eu.org>
	<20110111013152.GA23860@mail.hallyn.com>
	<20110114145001.GB20945@wavehammer.waldi.eu.org>
	<20110115003114.GA24569@mail.hallyn.com>
	<20110115113025.GB18682@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110115113025.GB18682-0IJIQSrh9RL9UF0aPl6fsj8Kkb2uy4ct@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM
List-Id: containers.vger.kernel.org

Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> On Sat, Jan 15, 2011 at 12:31:14AM +0000, Serge E. Hallyn wrote:
> > Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> > > On Tue, Jan 11, 2011 at 01:31:52AM +0000, Serge E. Hallyn wrote:
> > > > Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> > > > > What is this flag used for anyway? I only see it used in the accounting
> > > > > stuff, and if every user can get it, it is not longer useful.
> > > > hm, I'm not sure...  maybe noone is using it!
> > > However with your patches (or at least the goal), everyone is super-user
> > > in derived namespaces.
> > 
> > No, a task just sitting in a derived ns won't necessarily need/use
> > super-user privileges...  (and, if we ever get far enough along, it
> > won't even necessarily have CAP_SYS_ADMIN/etc targeted to the parent
> > userns, bc it won't need those to do the unshares).
> 
> The goal, as I understand it, is that everyone can create derived user
> namespaces. However the creator have automatically all the capabilities
> in the derived namespace.

Yes.  While he is root in that namespace.  But then he can drop
privileges and spawn new tasks, which have no capabilities in any
namespace.

Even if he didn't do that, the PF_SUPERPRIV flag doesn't say that
you have capabilities, but that you used them.  So if I star a task
as root which never does anything but ls /root, then the flag should
not be set.

> So he can use them to gain this super-user
> flag. Even killing a tasks in the derived namespace needs the capability
> already.

-serge
