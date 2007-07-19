From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: My netns patches updated to Linus' latest
Date: Thu, 19 Jul 2007 17:25:39 +0400
Message-ID: <469F6653.5000004@sw.ru>
References: <m1myxs3mbn.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1myxs3mbn.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> My next project is most likely going to be to dig in and make the
> loopback device a normal network device (not statically allocated)
> as a cleanup in preparation for the network namespace work.

I can do this :)

As far as I understand the code, loopback device is used in two fashions:
- as a real network device
- and as a "stable" never freed piece of memory
I presume, they should be separated.

As for device itself, there is a some sort of a template in a Pavel's
virtual ethernet device driver...

> Feel free to pick the patches apart.   Especially in the core of the
> network stack.

I think that a small plan of submitting process is a good idea, at least
we will be able to coordinate the efforts and work in parallel.

> I'm hoping to start seriously submitting patches short after the merge
> window closes.  So we can get a long test/review cycle.
:)

Regards,
	Den
