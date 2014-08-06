From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Tue, 05 Aug 2014 22:16:06 -0700
Message-ID: <87lhr2tcyx.fsf@x220.int.ebiederm.org>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<20140806144643.45e5dab8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140806144643.45e5dab8-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org> (Stephen Rothwell's
	message of "Wed, 6 Aug 2014 14:46:43 +1000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org> writes:

> Hi Eric,
>
> On Tue, 05 Aug 2014 17:57:31 -0700 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) wrote:
>>
>> Please pull the for-linus branch from the git tree:
>> 
>>    git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-linus
>> 
>>    HEAD: 344470cac42e887e68cfb5bdfa6171baf27f1eb5 proc: Point /proc/mounts at /proc/thread-self/mounts instead of /proc/self/mounts
>
> This has had 4 commits added since the merge window opened that have no
> Reviewed-by, Acked-by or Tested-by tags and only one Signed-off-by
> tag.

I am not certain what your point is.

There have been no commits added since the merge window opened.

There was one commit changed to fix a typo.  I documented that already.

There were some commits pushed to the tree as late as friday that had
been out for review earlier than that and it is possible that you did
not pick them up in linux-next until monday.  That doesn't mean I added
anything after the merge window opened.

I have also made certain all of these commits have at least had a chance
to show up in linux-next.

As for missing cool tags shrug.  The people looking at my code didn't
feel like saying the magic words so I didn't include cool tags.
Furthermore the code is all quite trivial.

Beyond that I have been quite out of it recently and this is what I had
time to do.  If I had had a little more time and energy I would have
included unmount on unlink patches that still need magic to happen to
keep from blowing the stack in pathological cases on everything except
x86_64.  That code has been sitting in linux-next.

Which is a my long winded way of say it sounds like you are accusing me
of being irresponsible, and my way of saying that I have tested and
vetted these trivial patches and been as careful as I reasonably could,
and I that I apologise for not being able to do things a few days
earlier.

Eric
