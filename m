From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH 3/3] netcls_cgroup: implement proper hierarchy support
Date: Mon, 19 Nov 2012 20:17:39 +0100
Message-ID: <50AA85D3.7070000__25016.1542477601$1353352684$gmane$org@monom.org>
References: <1353123062-23193-1-git-send-email-tj@kernel.org>
	<1353123062-23193-4-git-send-email-tj@kernel.org>
	<50AA385A.90503@monom.org> <20121119170859.GI15971@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121119170859.GI15971-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Tejun,

On 19.11.2012 18:08, Tejun Heo wrote:
> Hello, Daniel.
> 
> On Mon, Nov 19, 2012 at 02:47:06PM +0100, Daniel Wagner wrote:
>> On 17.11.2012 04:31, Tejun Heo wrote:
>>> @@ -112,15 +161,6 @@ struct cgroup_subsys net_cls_subsys = {
>>>   	.subsys_id	= net_cls_subsys_id,
>>>   	.base_cftypes	= ss_files,
>>>   	.module		= THIS_MODULE,
>>> -
>>> -	/*
>>> -	 * While net_cls cgroup has the rudimentary hierarchy support of
>>> -	 * inheriting the parent's classid on cgroup creation, it doesn't
>>> -	 * properly propagates config changes in ancestors to their
>>> -	 * descendents.  A child should follow the parent's configuration
>>> -	 * but be allowed to override it.  Fix it and remove the following.
>>> -	 */
>>> -	.broken_hierarchy = true,
>>>   };
>>
>> Are you sure you want to set the default to false at this point?
> 
> Hmmm.... why not?  It's now implementing proper hierarchy behavior.

Well, I though the rule is to keep API as stable as possible. On second
though this change will only extend the API, so for the existing
user base nothing changes.

Acked-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

thanks,
daniel
