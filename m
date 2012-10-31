From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 2/8] cgroup: kill CSS_REMOVED
Date: Wed, 31 Oct 2012 21:19:51 +0400
Message-ID: <50915DB7.5020706@parallels.com>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-3-git-send-email-tj@kernel.org>
	<20121031153926.GC22809@dhcp22.suse.cz>
	<20121031165739.GE2945@htj.dyndns.org>
	<50915A87.4070504@parallels.com>
	<CAOS58YP=CjTPFdETLRXnc3gXEzX2=EEe2dMdSh3Eov7zRfV4Qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOS58YP=CjTPFdETLRXnc3gXEzX2=EEe2dMdSh3Eov7zRfV4Qg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/31/2012 09:10 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Wed, Oct 31, 2012 at 10:06 AM, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
>> This is not the topic of this thread, but since you brought it:
>> If you take a look at the description patch in the patch I sent, the
>> problem I outlined is that at create time, we don't know anything about
>> which will the css_id be - and I would like to avoid creating yet
>> another index.
>>
>> Is there any way you would suggest of handling this ? Any chance of us
>> allocating the css_id earlier then?
> 
> I only glanced the patch description but the problem I'm trying to
> solve is locking - currently we don't have a place where a controller
> can tell a cgroup is becoming online; thus it has nothing to
> synchronized against and tell that a cgroup is alive or not.  As for
> css_id allocation, maybe you can deal with that in ->post_create() or
> maybe we can allocate css_id earlier (but where would it be stored?).
> I'll look into it.
> 

The css_id is allocated right after ->create(). So if post_create() is
called after that, I can use it just fine - which is what I do in my
patch. Problem is, since I do memory allocation based on that, it can fail.

So although I would have to look at your series myself to see exactly
what you are trying to achieve (looking forward), I seemed natural to me
to think about it terms of "early_create" + "late_create" (->create())
and ->post_create()), where the later is a callback when things are
readier (in this case, the css_id).

I don't see post_create failing as a huge problem. The natural
synchronization point would be "right after post_create" - then you can
definitely tell that it is online. Although this can be viewed a bit as
"exposing internals", creating is different then destroying: When you
create, you may not have all data yet. When destroying, you do - and
want to get rid of it. So this kind of bootstrapping is pretty standard
and common.
