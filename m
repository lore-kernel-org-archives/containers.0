From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] userns: Convert quota to user kuid/kgid where appropriate
Date: Wed, 01 Aug 2012 10:45:14 -0700
Message-ID: <87k3xi4ic5.fsf_-_@xmission.com>
References: <1343817532-12021-1-git-send-email-dmonakhov@openvz.org>
	<87d33abw7u.fsf@xmission.com> <87d33azks1.fsf@dmbot.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d33azks1.fsf-d2mB1LbBle8ox3rIn2DAYQ@public.gmane.org> (Dmitry Monakhov's message of "Wed,
	01 Aug 2012 19:36:46 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

> On Wed, 01 Aug 2012 06:03:33 -0700, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) wrote:
>> Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
>> 
>> > Map uid/gid to global kuid/kgid before pass it down to quota
>> > infrastructure.
>> 
>> Have you looked at my development branch of my userns tree?
>> 
>> I already have a patch queued to do something like this. 
> Oh. Yes you right. I've missed it.
> BTW when do you plan to submit new set?

I had hoped for 3.6 but I was a bit out of it earlier and didn't get my
testing/review in before the merge window opened.

So my current plan is to rebase on 3.6-rc1 and the place the patches
up for review and get them all staged for 3.7.

Eric
