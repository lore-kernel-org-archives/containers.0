From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Possible bug: detached mounts difficult to cleanup
Date: Wed, 11 Jan 2017 15:27:05 +1300
Message-ID: <87fukqwcue.fsf__46188.3363234394$1484101875$gmane$org@xmission.com>
References: <20170111012454.GB2497@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170111012454.GB2497-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org> (Krister Johansen's
	message of "Tue, 10 Jan 2017 17:24:54 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Krister Johansen <kjlx-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Krister Johansen <kjlx-6woCzk5+qv5TrMCiz+cRkdBPR1lH4CV8@public.gmane.org> writes:

> Gents,
>
> I wondered if a naive solution could re-walk the list of mounts
> processed in umount_tree() and if all of the detached but locked mounts
> had a refcount that indicated they're unused, they could be unlocked and
> unmounted.  At least in the case of the containers I'm dealing with, the
> the container software should be ensuring that nothing in the container
> has a reference on anything that's under the detached portion of the
> tree.  However, there's probably a better way to do this.

So if the code is working correctly that should already happen.

The design is for the parent mount to hold a reference to the submounts.
And when the reference on the parent drops to 0.  The references on
all of the submounts will also be dropped.

I was hoping to read the code and point it out to you quickly, but I am
not seeing it now.  I am wondering if in all of the refactoring of that
code something was dropped/missed :(

Somewhere there is supposed to be the equivalent of:
	pin_insert_group(&p->mnt_umount, &p->mnt_parent->mnt, &unmounted);
when we unhash those mounts because the last count has gone away.
Either it is very sophisticated or I am missing it.  Grr....

Eric
