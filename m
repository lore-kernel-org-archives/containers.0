From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: My netns patches updated to Linus' latest
Date: Thu, 19 Jul 2007 07:53:16 -0600
Message-ID: <m1ejj433g3.fsf@ebiederm.dsl.xmission.com>
References: <m1myxs3mbn.fsf@ebiederm.dsl.xmission.com> <469F6653.5000004@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <469F6653.5000004-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Thu, 19
	Jul 2007 17:25:39 +0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:

> Eric W. Biederman wrote:
>> My next project is most likely going to be to dig in and make the
>> loopback device a normal network device (not statically allocated)
>> as a cleanup in preparation for the network namespace work.
>
> I can do this :)
>
> As far as I understand the code, loopback device is used in two fashions:
> - as a real network device
> - and as a "stable" never freed piece of memory
> I presume, they should be separated.

Essentially.  As far as that goes I think my patchset already covers that
aspect of it.  Although there may be an initialization or shutdown
races that I currently do not handle.

Right now I'm working on a building up a clean patchset, and one of
the basic rules is that cleanups should happen before features are
added.  Which means that before we move a pointer to the loopback
device into a per network namespace structure we should make it
dynamically allocated if possible.

> As for device itself, there is a some sort of a template in a Pavel's
> virtual ethernet device driver...

Yes.  The tricky bits are mostly in the code review for making
certain that the loopback device isn't used after it is freed.

>> Feel free to pick the patches apart.   Especially in the core of the
>> network stack.
>
> I think that a small plan of submitting process is a good idea, at least
> we will be able to coordinate the efforts and work in parallel.

Yes.  Working in parallel would be good.  However the bottleneck I
see is is patch submission, review and acceptance.  Not so much
development of working patches.

So as much internal review and testing we can do before the patches
get to Dave Miller the better our chances (so long as we continue to
think about what is best for the network stack as a whole and not what
is best for network namespaces).

Eric
