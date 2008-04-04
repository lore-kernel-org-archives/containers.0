From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: RE: [RFC][patch 8/11][CFQ-cgroup] Control cfq_data per cgroup
Date: Fri, 4 Apr 2008 18:46:53 +0900
Message-ID: <018c01c89638$d01d3850$7057a8f0$__29277.3636211225$1207302623$gmane$org@jp.nec.com>
References: <007801c893d9$d89726f0$89c574d0$@jp.nec.com>	
	<008501c893dc$3206e520$9614af60$@jp.nec.com>	
	<6599ad830804030835s73392db0v29426425c0ea4381@mail.gmail.com>	
	<003401c8961c$00eea670$02cbf350$@jp.nec.com>
	<6599ad830804040200u1ed48f4bxecaa664862cf30a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830804040200u1ed48f4bxecaa664862cf30a5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: ja
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: 'Paul Menage' <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> 
> On Thu, Apr 3, 2008 at 11:20 PM, Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
> wrote:
> >
> >  So that you say, root subsystem state maybe keep a reference locally.
> >  For example, create a variable for root subsystem state and
> >  store the pointer when making subsystem state first.
> 
> Yes, that's what I'm suggesting.
> 
> >
> >  However, I think that it is smart to calculate root group of subsystems
> >  when needing its information.
> 
> I don't see why it's better to go through the cgroup subsystem to
> retrieve the reference.
> 

If program have temporary data, it may cause inconsistency.
I think that information should be referred to original(control mechanism).

Information of cgroup is controlled at cgroup subsystem (and cgroupfs_root).
So, I think that it's better to query into cgroup subsystem.

Now, cgroup susbsystem would not change root group.
Therefore, system would also runs by your suggestion.

I will consider this issue.

Thanks,
 Satoshi UCHIDA.
