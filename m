From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 03/10] cgroup: implement cgroup_add_cftypes() and friends
Date: Tue, 20 Mar 2012 20:04:57 +0400
Message-ID: <4F68AAA9.3060205@parallels.com>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
	<1331940963-15756-4-git-send-email-tj@kernel.org>
	<877gyfu025.fsf@linux.vnet.ibm.com>
	<20120320160347.GE5684@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120320160347.GE5684-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/20/2012 08:03 PM, Tejun Heo wrote:
> Hello, Aneesh.
>
> On Tue, Mar 20, 2012 at 02:22:02PM +0530, Aneesh Kumar K.V wrote:
>> Instead of using CGROUP_SUBSYS_CFTYPES_COND, are you ok if other
>> subsystem called cgroup_add_cftypes ?. I am looking at how this will
>> impact http://article.gmane.org/gmane.linux.kernel.mm/75470 . With
>> HugeTLB we cannot do the above.
>
> Yeah, sure.  Allowing dyanmic additions and removals of cftypes is the
> whole point of the patchset.
>
> Thanks.
>

Aneesh,

I think what I ended up doing for the sock memcg will suit you quite well.

Stay tuned.
