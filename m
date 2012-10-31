From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 2/8] cgroup: kill CSS_REMOVED
Date: Wed, 31 Oct 2012 21:06:15 +0400
Message-ID: <50915A87.4070504@parallels.com>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-3-git-send-email-tj@kernel.org>
	<20121031153926.GC22809@dhcp22.suse.cz>
	<20121031165739.GE2945@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121031165739.GE2945-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

On 10/31/2012 08:57 PM, Tejun Heo wrote:
> I have a patch queued to add ->pre_destroy() - different from
> Glauber's in that it can't fail, so we'll have
> 
> 	->create()
> 		->post_create()
> 		->pre_destroy()
> 	->destroy()
> 
> Where ->create() may fail but none other can. 

This is not the topic of this thread, but since you brought it:
If you take a look at the description patch in the patch I sent, the
problem I outlined is that at create time, we don't know anything about
which will the css_id be - and I would like to avoid creating yet
another index.

Is there any way you would suggest of handling this ? Any chance of us
allocating the css_id earlier then?
