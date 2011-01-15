From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 4/7] allow killing tasks in your own or child userns
Date: Sat, 15 Jan 2011 12:30:25 +0100
Message-ID: <20110115113025.GB18682__23854.3029329323$1295091078$gmane$org@wavehammer.waldi.eu.org>
References: <20110110211135.GA22446@mail.hallyn.com>
	<20110110211334.GD22564@mail.hallyn.com>
	<20110110215240.GA21351@wavehammer.waldi.eu.org>
	<20110110225151.GA18944@localhost>
	<20110110232335.GA27029@wavehammer.waldi.eu.org>
	<20110111013152.GA23860@mail.hallyn.com>
	<20110114145001.GB20945@wavehammer.waldi.eu.org>
	<20110115003114.GA24569@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110115003114.GA24569-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Jan 15, 2011 at 12:31:14AM +0000, Serge E. Hallyn wrote:
> Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> > On Tue, Jan 11, 2011 at 01:31:52AM +0000, Serge E. Hallyn wrote:
> > > Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> > > > What is this flag used for anyway? I only see it used in the accounting
> > > > stuff, and if every user can get it, it is not longer useful.
> > > hm, I'm not sure...  maybe noone is using it!
> > However with your patches (or at least the goal), everyone is super-user
> > in derived namespaces.
> 
> No, a task just sitting in a derived ns won't necessarily need/use
> super-user privileges...  (and, if we ever get far enough along, it
> won't even necessarily have CAP_SYS_ADMIN/etc targeted to the parent
> userns, bc it won't need those to do the unshares).

The goal, as I understand it, is that everyone can create derived user
namespaces. However the creator have automatically all the capabilities
in the derived namespace. So he can use them to gain this super-user
flag. Even killing a tasks in the derived namespace needs the capability
already.

Bastian

-- 
Those who hate and fight must stop themselves -- otherwise it is not stopped.
		-- Spock, "Day of the Dove", stardate unknown
