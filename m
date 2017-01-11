From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: Possible bug: detached mounts difficult to cleanup
Date: Wed, 11 Jan 2017 02:51:33 +0000
Message-ID: <20170111025132.GP1555__29059.7726394937$1484103109$gmane$org@ZenIV.linux.org.uk>
References: <20170111012454.GB2497@templeofstupid.com>
	<87fukqwcue.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87fukqwcue.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jan 11, 2017 at 03:27:05PM +1300, Eric W. Biederman wrote:

> The design is for the parent mount to hold a reference to the submounts.
> And when the reference on the parent drops to 0.  The references on
> all of the submounts will also be dropped.

Parent does _not_ hold any references to submounts.  Never had.  What
happens in umount_tree() is that any surviving submounts
	a) are inserted into ->mnt_pins of parent, but not into unmounted.
	a) have the reference to parent dropped.

When the last reference to parent gets dropped, all remaining submounts
get unhashed and when we get to cleanup_mnt() on parent, ->mnt_pins
gets pulled.  Which does dput() on (ex)mountpoints and mntput() on
those submounts.

> I was hoping to read the code and point it out to you quickly, but I am
> not seeing it now.  I am wondering if in all of the refactoring of that
> code something was dropped/missed :(
> 
> Somewhere there is supposed to be the equivalent of:
> 	pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt, &unmounted);
> when we unhash those mounts because the last count has gone away.
> Either it is very sophisticated or I am missing it.  Grr....

What you are missing is that they never end up on 'unmounted' - only on
->mnt_pin of parent.  It's the same pin_insert_group() in umount_tree()
as for everything else, the only difference being that it does _not_
get kicked out on the namespace_unlock().
