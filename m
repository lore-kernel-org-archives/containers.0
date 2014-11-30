From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [CFT][PATCH] mnt: Implicitly add MNT_NODEV on remount when it was
	implicitly added by mount
Date: Sun, 30 Nov 2014 12:46:48 -0600
Message-ID: <873890jzl3.fsf@x220.int.ebiederm.org>
References: <20141127101105.GA30605@linux-rxt1.site>
	<87k32dlicc.fsf@x220.int.ebiederm.org>
	<87egsllia3.fsf_-_@x220.int.ebiederm.org>
	<CALCETrX=B+0PVe8fhvCEyqBGD-D1wLJPd6CrqPn6LCGYgzxPMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrX=B+0PVe8fhvCEyqBGD-D1wLJPd6CrqPn6LCGYgzxPMg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andy Lutomirski's message of "Sat, 29 Nov 2014 16:07:48 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, joeyli <jlee-IBi9RG/b67k@public.gmane.org>, Jim Fehlig <jfehlig-IBi9RG/b67k@public.gmane.org>, Cedric Bosdonnat <cbosdonnat-IBi9RG/b67k@public.gmane.org>
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:

> On Nov 29, 2014 4:06 PM, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>>
>> Now that remount is properly enforcing the rule that you can't remove
>> nodev at leastsandstorm.iois breaking when performing a remount.
>>
>> It turns out that there is an easy intuitive solution implicitly
>> add nodev on remount when nodev was implicitly added on mount.
>
> Is this intended to be a permanent fix or are you planning on
> replacing it with something closer to my version for 3.19?
>
> http://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=userns/fix_magic_nodev&id=bf8b198add82a249d6da4ecf280c30a0865637f6
>
> I still think that the implicit nodev behavior is a bad idea in
> general.

I want to consider your change as part of the larger discussion about
how we take the final step towards allowing fuse and other filesystems
with backing store to be merged in the kernel.

There are actually some other possibilities with s_user_ns in the mix.

The cleanest solution is probably to declare dev_t as well as security
labels values that are interpreted with respect to user namespaces.
Then seeting s_user_ns != &init_user_ns will yield device nodes that
simply don't have a meaning in the kernel.  Which winds up being
effectively the same as an implicit nodev, but without the compatibility
hassle.

But all of that is or should be development.  And what my patch is, is
about getting a simple bug fix that works.

Eric
