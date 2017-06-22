From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] Enable namespaced file capabilities
Date: Thu, 22 Jun 2017 16:09:25 -0500
Message-ID: <20170622210925.GA32691@mail.hallyn.com>
References: <1498157989-11814-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<70a09f1b-e82c-a25c-9325-d5d757b1b695@schaufler-ca.com>
	<10fb9c1b-e9af-336c-9a1b-cf95259cfaf3@linux.vnet.ibm.com>
	<2bf08b3e-27f4-3592-d5e2-a823401ac644@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2bf08b3e-27f4-3592-d5e2-a823401ac644-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
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
Cc: zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Casey Schaufler (casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org):
> On 6/22/2017 1:12 PM, Stefan Berger wrote:
> > On 06/22/2017 03:59 PM, Casey Schaufler wrote:
> >> On 6/22/2017 11:59 AM, Stefan Berger wrote:
> >>> This series of patches primary goal is to enable file capabilities
> >>> in user namespaces without affecting the file capabilities that are
> >>> effective on the host. This is to prevent that any unprivileged user
> >>> on the host maps his own uid to root in a private namespace, writes
> >>> the xattr, and executes the file with privilege on the host.
> >>>
> >>> We achieve this goal by writing extended attributes with a different
> >>> name when a user namespace is used. If for example the root user
> >>> in a user namespace writes the security.capability xattr, the name
> >>> of the xattr that is actually written is encoded as
> >>> security.capability@uid=1000 for root mapped to uid 1000 on the host.
> >> You need to identify the instance of the user namespace for
> >> this to work right on a system with multiple user namespaces.
> >> If I have a shared filesystem mounted in two different user
> >> namespaces a change by one will affect the other.
> >
> > Two different user namespaces with different uid mappings will not affect each other.
> 
> But two namespaces with the same uid mapping will, and I
> don't think this meets the principle of least astonishment.

It does.  If you have one filesystem shared among multiple
containers, then it needs to be either read-only, or you
need to know what you're doing.

> I also object to associating capabilities with UIDs. The
> whole point of capabilities is to disassociate UID 0 from
> privilege. What you've done is explicitly associate a UID
> with the ability to have privilege. That's an architectural
> regression.

IMO this is looking at it the wrong way.  From inside the container's
viewpoint, the capabilities are not associated with a uid.  Any
task, regardles off uid, in the container, which executes the file,
gets the privilege.  IMO that satisfies the intent of file capabilities.

-serge
