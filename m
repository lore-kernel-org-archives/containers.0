From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [RFC] Per-user namespace process accounting
Date: Sat, 07 Jun 2014 14:39:04 -0700
Message-ID: <1402177144.2236.26.camel@dabdike.int.hansenpartnership.com>
References: <5386D58D.2080809@1h.com> <87tx88nbko.fsf@x220.int.ebiederm.org>
	<53870EAA.4060101@1h.com> <20140529153232.GB9714@ubuntumail>
	<538DFF72.7000209@parallels.com> <20140603172631.GL9714@ubuntumail>
	<8738flkhf0.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8738flkhf0.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2014-06-03 at 10:54 -0700, Eric W. Biederman wrote:
> Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Pavel Emelyanov (xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
> >> On 05/29/2014 07:32 PM, Serge Hallyn wrote:
> >> > Quoting Marian Marinov (mm-108MBtLGafw@public.gmane.org):
> >> >> We are not using NFS. We are using a shared block storage that offers us snapshots. So provisioning new containers is
> >> >> extremely cheep and fast. Comparing that with untar is comparing a race car with Smart. Yes it can be done and no, I
> >> >> do not believe we should go backwards.
> >> >>
> >> >> We do not share filesystems between containers, we offer them block devices.
> >> > 
> >> > Yes, this is a real nuisance for openstack style deployments.
> >> > 
> >> > One nice solution to this imo would be a very thin stackable filesystem
> >> > which does uid shifting, or, better yet, a non-stackable way of shifting
> >> > uids at mount.
> >> 
> >> I vote for non-stackable way too. Maybe on generic VFS level so that filesystems 
> >> don't bother with it. From what I've seen, even simple stacking is quite a challenge.
> >
> > Do you have any ideas for how to go about it?  It seems like we'd have
> > to have separate inodes per mapping for each file, which is why of
> > course stacking seems "natural" here.
> >
> > Trying to catch the uid/gid at every kernel-userspace crossing seems
> > like a design regression from the current userns approach.  I suppose we
> > could continue in the kuid theme and introduce a iiud/igid for the
> > in-kernel inode uid/gid owners.  Then allow a user privileged in some
> > ns to create a new mount associated with a different mapping for any
> > ids over which he is privileged.
> 
> There is a simple solution.
> 
> We pick the filesystems we choose to support.
> We add privileged mounting in a user namespace.
> We create the user and mount namespace.
> Global root goes into the target mount namespace with setns and performs
> the mounts.
> 
> 90% of that work is already done.
> 
> As long as we don't plan to support XFS (as it XFS likes to expose it's
> implementation details to userspace) it should be quite straight
> forward.

Any implementation which doesn't support XFS is unviable from a distro
point of view.  The whole reason we're fighting to get USER_NS enabled
in distros goes back to lack of XFS support (they basically refused to
turn it on until it wasn't a choice between XFS and USER_NS).  If we put
them in a position where they choose a namespace feature or XFS, they'll
choose XFS.

XFS developers aren't unreasonable ... they'll help if we ask.  I mean
it was them who eventually helped us get USER_NS turned on in the first
place.

James
