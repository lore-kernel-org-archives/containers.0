From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Unprivileged containers and co-ordinating user namespaces
Date: Wed, 04 May 2016 14:21:33 -0400
Message-ID: <1462386093.14310.93.camel__2853.46618989042$1462386112$gmane$org@HansenPartnership.com>
References: <1461880928.2307.48.camel@HansenPartnership.com>
	<20160428230045.GS22888@odin.tremily.us>
	<1461944328.2311.10.camel@HansenPartnership.com>
	<87wpn9988a.fsf@x220.int.ebiederm.org>
	<1462385876.14310.90.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1462385876.14310.90.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2016-05-04 at 14:17 -0400, James Bottomley wrote:
> > Certainly it has been that way for quite a while now.
> 
> I don't quite get this.  If setgroups is set to deny and I have a set
> of group mappings, I still can't get rid of the negative acl group. 
>  I can map it to a different gid inside my container, or I can not 
> map  it at all, but in either case I still can't get access to 
> anything with the negative acl group marker because the group 
> permission checks occurs with the kguid_t set which includes my 
> mapped or unmapped group.  The only way I can lose it is to call
> sys_setgroups().

Sorry, this next bit should be at the end of the email (I was playing
and typing at the same time):

> It's a bit ugly because I have to enter the container with --preserve
> -credentials and I can't su to myself if I enter as root (-S 0), I 
> have to re-enter as myself instead, but it works.
> 
> > Except for the negative acl aspect there are no issues with 
> > dropping groups, as setgroups will limit you to the groups allowed 
> > in your user namespace.
> 
> Well, notwithstanding the merits of negative acls, which I don't want
> to debate because I don't think they're that useful, the use case 
> might be that a user possessing a negative acl still wants to use an
> architecture emulation container for building.  Installing such a
> container requires being able to set a set of groups and uids 
> (required by the installer), but it doesn't require the 
> sys_setgroups() system call, so they could reasonably be given the 
> ability to set one up with the nosetgroups flag and a range of gids 
> allocated in subgid to ensure they still can't get access to 
> resources denied by the negative acl group.

It's a bit ugly because I have to enter the container with --preserve
-credentials and I can't su to myself if I enter as root (-S 0), I have
to re-enter as myself instead, but it works.

James
