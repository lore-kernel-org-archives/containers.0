From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 05/17] cgroup: cgroup->dentry isn't a RCU pointer
Date: Thu, 15 Nov 2012 07:00:11 +0400
Message-ID: <50A45ABB.3040507__25602.155554998$1352919620$gmane$org@parallels.com>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
	<1352775704-9023-6-git-send-email-tj@kernel.org>
	<50A37B0A.7010608@parallels.com>
	<20121114185504.GG21185@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121114185504.GG21185-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/14/2012 10:55 PM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Wed, Nov 14, 2012 at 03:05:46PM +0400, Glauber Costa wrote:
>> Will memcontrol.c need similar amendments?
>>
>> The code that lives in -mm and includes kmemcg includes the following
>> excerpt:
>>
>>         rcu_read_lock();
>>         dentry = rcu_dereference(memcg->css.cgroup->dentry);
>>         rcu_read_unlock();
> 
> Ooh, yeah, hmmm... that should happen after this series gets merged.
> I'll mark it as pending.
> 
> Thanks.
> 
Btw: I did this because there is no other facility to figure out a
memcg's "name".

I wonder if there is anyone else using this, so we could just abstract
that in cgroup.c?
