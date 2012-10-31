From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCHSET] cgroup: simplify cgroup removal path
Date: Wed, 31 Oct 2012 21:24:06 +0400
Message-ID: <50915EB6.3060704__47071.3380877443$1351704283$gmane$org@parallels.com>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<50912C6D.6020000@parallels.com>
	<20121031171849.GH2945@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121031171849.GH2945-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/31/2012 09:18 PM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Oct 31, 2012 at 05:49:33PM +0400, Glauber Costa wrote:
>> The only think that drew my attention is that you are changing the
>> local_irq_save callsite to local_irq_disable. It shouldn't be a problem,
>> since this is never expected to be called in interrupt context.
>>
>> Still... it makes me wonder if that disabled-interrupt block is still
>> needed? According to the changelogs, it was introduced in e7c5ec919 for
>> the css_tryget mechanism. But css_tryget itself will never scan
>> subsystems, so if we can no longer fail, we should be able to just ditch
>> it. Unless I am missing something
> 
> Note both in the commit messages.
> 

I am sorry, but I can't find anything that may be related to this in the
commit messages. Can you be more specific ?
