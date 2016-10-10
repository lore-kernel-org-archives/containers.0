From: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH v2] mount: dont execute propagate_umount() many times for
	same mounts
Date: Mon, 10 Oct 2016 13:42:32 -0700
Message-ID: <20161010204218.GB31628@outlook.office365.com>
References: <1475772564-25627-1-git-send-email-avagin@openvz.org>
	<87eg3tclbd.fsf@x220.int.ebiederm.org>
	<20161006230616.GA2296@outlook.office365.com>
	<87twcoahs3.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87twcoahs3.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Oct 06, 2016 at 11:45:48PM -0500, Eric W. Biederman wrote:
> Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> writes:
> 
> > On Thu, Oct 06, 2016 at 02:46:30PM -0500, Eric W. Biederman wrote:
> >> Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
> >> 
> >> > The reason of this optimization is that umount() can hold namespace_sem
> >> > for a long time, this semaphore is global, so it affects all users.
> >> > Recently Eric W. Biederman added a per mount namespace limit on the
> >> > number of mounts. The default number of mounts allowed per mount
> >> > namespace at 100,000. Currently this value is allowed to construct a tree
> >> > which requires hours to be umounted.
> >> 
> >> I am going to take a hard look at this as this problem sounds very
> >> unfortunate.  My memory of going through this code before strongly
> >> suggests that changing the last list_for_each_entry to
> >> list_for_each_entry_reverse is going to impact the correctness of this
> >> change.
> >
> > I have read this code again and you are right, list_for_each_entry can't
> > be changed on list_for_each_entry_reverse here.
> >
> > I tested these changes more carefully and find one more issue, so I am
> > going to send a new patch and would like to get your comments to it.
> >
> > Thank you for your time.
> 
> No problem.
> 
> A quick question.  You have introduced lookup_mnt_cont.  Is that a core
> part of your fix or do you truly have problmenatic long hash chains.

Actually I need a slightly modified copy of __lookup_mnt_last() to set
mark for mounts with the MNT_UMOUNT flag.

> 
> Simply increasing the hash table size should fix problems long hash
> chains (and there are other solutions like rhashtable that may be more
> appropriate than pre-allocating large hash chains).
> 
> If it is not long hash chains introducing lookup_mnt_cont in your patch
> is a distraction to the core of what is going on.
> 
> Perhaps I am blind but if the hash chains are not long I don't see mount
> propagation could be more than quadratic in the worst case.  As there is
> only a loop within a loop.  Or Is the tree walking in propagation_next
> that bad?

I don't think that the hash chains are long here.

The complexity of __lookup_mnt() is O(n). In our case the hash size
(4096) is smaller than a number of elements. If we increase the hash
size, it will be faster but the coplexity in term of O() will be the
same, will it not?

Here are all nested steps where we enumirate mounts:
    * Enumirate all mounts in a target tree (propagate_umount)
    * Enumirate mounts to find where these changes have to
      be propagated (mark_umount_candidates)
    * Enumirate mounts to find a requered mount by parent and dentry
      (__lookup_mnt_last)

And my measurements proves that it isn't O(n^2):
    mounts |  (sec)  |
    ------------
    1024   | 0.08
    2048   | 0.4
    4096   | 3.2
    8192   | 50.8
    16384  | 810

> 
> Eric
