From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2] mount: dont execute propagate_umount() many times for
	same mounts
Date: Thu, 06 Oct 2016 23:45:48 -0500
Message-ID: <87twcoahs3.fsf@x220.int.ebiederm.org>
References: <1475772564-25627-1-git-send-email-avagin@openvz.org>
	<87eg3tclbd.fsf@x220.int.ebiederm.org>
	<20161006230616.GA2296@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161006230616.GA2296-1ViLX0X+lBJGNQ1M2rI3KwRV3xvJKrda@public.gmane.org> (Andrei Vagin's
	message of "Thu, 6 Oct 2016 16:06:28 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> writes:

> On Thu, Oct 06, 2016 at 02:46:30PM -0500, Eric W. Biederman wrote:
>> Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
>> 
>> > The reason of this optimization is that umount() can hold namespace_sem
>> > for a long time, this semaphore is global, so it affects all users.
>> > Recently Eric W. Biederman added a per mount namespace limit on the
>> > number of mounts. The default number of mounts allowed per mount
>> > namespace at 100,000. Currently this value is allowed to construct a tree
>> > which requires hours to be umounted.
>> 
>> I am going to take a hard look at this as this problem sounds very
>> unfortunate.  My memory of going through this code before strongly
>> suggests that changing the last list_for_each_entry to
>> list_for_each_entry_reverse is going to impact the correctness of this
>> change.
>
> I have read this code again and you are right, list_for_each_entry can't
> be changed on list_for_each_entry_reverse here.
>
> I tested these changes more carefully and find one more issue, so I am
> going to send a new patch and would like to get your comments to it.
>
> Thank you for your time.

No problem.

A quick question.  You have introduced lookup_mnt_cont.  Is that a core
part of your fix or do you truly have problmenatic long hash chains.

Simply increasing the hash table size should fix problems long hash
chains (and there are other solutions like rhashtable that may be more
appropriate than pre-allocating large hash chains).

If it is not long hash chains introducing lookup_mnt_cont in your patch
is a distraction to the core of what is going on.

Perhaps I am blind but if the hash chains are not long I don't see mount
propagation could be more than quadratic in the worst case.  As there is
only a loop within a loop.  Or Is the tree walking in propagation_next
that bad?

Eric
