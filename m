From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroup: implement cgroup.subtree_populated for the
	default hierarchy
Date: Wed, 16 Apr 2014 09:30:32 +0800
Message-ID: <534DDD38.9090800__37539.4825161949$1397611965$gmane$org@huawei.com>
References: <1397511846-2904-1-git-send-email-tj@kernel.org>
	<1397511846-2904-4-git-send-email-tj@kernel.org>
	<534C83F1.9020106@huawei.com>
	<20140415145450.GL1863@htj.dyndns.org>
	<20140415165221.GD30990@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140415165221.GD30990-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: rlove-L7G0xEPcOZbYtjvyW6yDsg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john-jueV0HHMeujJJrXXpGQQMAC/G2K4zDHf@public.gmane.org
List-Id: containers.vger.kernel.org

On 2014/4/16 0:52, Tejun Heo wrote:
> On Tue, Apr 15, 2014 at 10:54:50AM -0400, Tejun Heo wrote:
>> Hello,
>>
>> On Tue, Apr 15, 2014 at 08:57:21AM +0800, Li Zefan wrote:
>>> Is cgroup.tree_populated a better name?
>>>
>>> cgroup.subtree_control controls child cgroups only, but .subtree_populated
>>> shows 1 if there're tasks in the cgroup or its children, so the two
>>> are a bit inconsistent to me.
>>
>> Yes, good catch.  subtree_control affects subtree proper.
>> subtree_populated covers self too.  The difference is subtle and the
>> trade off between shared pattern in names and clarifying the subtlety
>> didn't seem clear-cut to me.  Hmmm....
> 
> How about cgroup.populated?
> 

Yeah, fine for me.
