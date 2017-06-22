From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Thu, 22 Jun 2017 18:07:36 -0500
Message-ID: <20170622230736.GA2477__30051.7611358829$1498172862$gmane$org@mail.hallyn.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<70a09f1b-e82c-a25c-9325-d5d757b1b695@schaufler-ca.com>
	<10fb9c1b-e9af-336c-9a1b-cf95259cfaf3@linux.vnet.ibm.com>
	<2bf08b3e-27f4-3592-d5e2-a823401ac644@schaufler-ca.com>
	<20170622210925.GA32691@mail.hallyn.com>
	<45e59e2e-0e00-cb9a-2f85-dc4606338a08@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <45e59e2e-0e00-cb9a-2f85-dc4606338a08-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Cc: zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org):
> On 6/22/2017 2:09 PM, Serge E. Hallyn wrote:
> > Quoting Casey Schaufler (casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org):
> >> On 6/22/2017 1:12 PM, Stefan Berger wrote:
> >>> On 06/22/2017 03:59 PM, Casey Schaufler wrote:
> >>>> On 6/22/2017 11:59 AM, Stefan Berger wrote:
> >>>>> This series of patches primary goal is to enable file capabilities
> >>>>> in user namespaces without affecting the file capabilities that are
> >>>>> effective on the host. This is to prevent that any unprivileged user
> >>>>> on the host maps his own uid to root in a private namespace, writes
> >>>>> the xattr, and executes the file with privilege on the host.
> >>>>>
> >>>>> We achieve this goal by writing extended attributes with a different
> >>>>> name when a user namespace is used. If for example the root user
> >>>>> in a user namespace writes the security.capability xattr, the name
> >>>>> of the xattr that is actually written is encoded as
> >>>>> security.capability@uid=1000 for root mapped to uid 1000 on the host.
> >>>> You need to identify the instance of the user namespace for
> >>>> this to work right on a system with multiple user namespaces.
> >>>> If I have a shared filesystem mounted in two different user
> >>>> namespaces a change by one will affect the other.
> >>> Two different user namespaces with different uid mappings will not affect each other.
> >> But two namespaces with the same uid mapping will, and I
> >> don't think this meets the principle of least astonishment.
> > It does.  If you have one filesystem shared among multiple
> > containers, then it needs to be either read-only, or you
> > need to know what you're doing.
> 
> Joe's a junior devop who has been given a container
> template which he tweaks for various nefarious purposes.
> He doesn't know much about what he's doing. He isn't
> changing the UIDs the template uses because, quite frankly,
> he doesn't know a UID from an entrenching tool. He has
> changed a filesystem from RO to RW because he read on a
> forum somewhere that doing so would fix a problem he had
> once. He doesn't want to have that problem again, so he
> left the change in the template.
> 
> Containers are being sold as a way to make things easier.
> This sort of side effect is dangerous in an environment
> where users are being told that they don't have to worry
> so much, the environment will take care of them. 
> 
> >> I also object to associating capabilities with UIDs. The
> >> whole point of capabilities is to disassociate UID 0 from
> >> privilege. What you've done is explicitly associate a UID
> >> with the ability to have privilege. That's an architectural
> >> regression.
> > IMO this is looking at it the wrong way.
> 
> The right way to look at the problem is to identify the
> capabilities the program ought to have and set the file
> capabilities and UID/GID properly on the program on the
> base system.

No.

Absolutely not.

That would require me to be given CAP_SETFCAP on the host in
order to control the resources I've been delegated in a user
namespace.  That's not how it works.

Using only /usr/bin/newuidmap and /usr/bin/newgidmap, which
allow me to map the subuids which I have been delegated through
/etc/subuid and /etc/subgid, I can, as an unprivileged user, and
with no other privilege, create a full container image, start it
up, and administer it.

The fact that I cannot also install software with file capabilities
is a shortcoming.

>  If you have to fix the program so it works
> right under those conditions, so much the better for
> everyone. If you're running with different capabilities
> in a container to prevent the program from doing damage
> to the base system, maybe the program needs fixing instead.

That is not the reason to do this.

Root in the container is assigning file capabilities for the
usual reason - to allow the file to be executed, by anyone,
regardless of uid (mapped into the namespace), with certain privilege.

The privilege which root in the container is allowed to
delegate is only the privilege which it *has* in the container.

If we allow root in the container to assign a 'global'
security.capability, then we are allow root in the container
to hand privilege to an unprivileged user on the host, against
host resources.

> > From inside the container's
> > viewpoint, the capabilities are not associated with a uid.  Any
> > task, regardles off uid, in the container, which executes the file,
> > gets the privilege.  IMO that satisfies the intent of file capabilities.
> 
> The UID is the wrong association. The namespace is the correct association.

That's a pleasant but impractical thought.  Namespaces do not have any
persistent ids.  (And if we tried, we'd be told no because it would
require a namespace of namespaces).

> You're using the UID because it's something that's different in the
> namespace than in the base system.

I'm using the uid because that is the subject which was granted privilege
over all other ids mapped into its user namespace.

>  You can detect it. What you need is a
> non-volatile namespace id to attach to the file rather than using the
> UID mapping (which may not be unique) that the namespace uses.

That's what we were trying to do in 2010.  It didn't work.  Which is
how we have the uid namespace as it exists.

-serge
