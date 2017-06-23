From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Fri, 23 Jun 2017 12:20:16 -0500
Message-ID: <20170623172016.GA19551@mail.hallyn.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<CAOQ4uxj=_Riih1K+QOYasZU8vZKCSrsg393f=17mJ2O-909e=Q@mail.gmail.com>
	<20170623160026.GA18257@mail.hallyn.com>
	<aa62373e-7cd6-39dd-2e38-2b6d6dbe18a8@schaufler-ca.com>
	<20170623163030.GA18820@mail.hallyn.com>
	<1498237641.3641.15.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1498237641.3641.15.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting James Bottomley (James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org):
> On Fri, 2017-06-23 at 11:30 -0500, Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org):
> > > Or maybe just security.ns.capability, taking James' comment into
> > > account.
> > 
> > That last one may be suitable as an option, useful for his particular
> > (somewhat barbaric :) use case, but it's not ok for the general
> > solution.
> > 
> > If uid 1000 was delegated the subuids 100000-199999, it should be 
> > able to write a file capability for use by his subuids, but that file
> > capability must not apply to other subuids.
> 
> I don't think it's barbaric, I think it's the common use case.  Let me

:)  sorry.  Yes, it is the common case, and even lxd does it that way.
But lxc itself does not, and while there are shortcomings (including
this one, file capabilities) which require 'barbaric' use of privilege
to set things up in some cases, I prefer we not get complacent and accept
it as proper.

> give a more comprehensible answer in terms of docker and IMA.  Lets
> suppose I'm running docker locally and in a test cloud both with userns
> enabled.
> 
> I build an image locally, mapping my uid (1000) to root.  If I begin
> with a standard base, each of the files has a security.ima signature. 
>  Now I add my layer, which involves updating a file, so I need to write
> a new signature to security.ima.  Because I'm running user namespaced,
> the update gets written at security.ima@uid=1000 when I do a docker
> save. 
> 
> Now supposing I deploy that image to a cloud.  As a tenant, the cloud
> gives me real uid 4531 and maps that to root.  Execution of the binary
> fails because it tries to use the underlying signature (in
> security.ima) as there is no xattr named security.ima@uid=4531

In this example, how do you, if you do, shift the owner of the file
into the mapped user namespace?  Or are you happy to have the file owned
by an invalid user nobody?  (There certainly are cases where that would
be ok, but I suspect you're shifting the file)

> So my essential point is that building the real kuid into the permanent
> record of the xattr damages image portability, which is touted as one
> of the real advantages of container images.

'container images' aren't portable in that sense now - for at least
many cases - because you have to shift the uid.  However you're doing
that, you may be able to shift the xattr the same way.

-serge
