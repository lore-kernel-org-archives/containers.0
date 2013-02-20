From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 01/10] netfilter: make /proc/net/netfilter pernet
Date: Wed, 20 Feb 2013 14:36:26 +0800
Message-ID: <51246EEA.5020301__28754.8349042938$1361342173$gmane$org@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20130207183318.GA18359@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130207183318.GA18359@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lve-ke3WRBg/xIg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Pablo,
On 2013/02/08 02:33, Pablo Neira Ayuso wrote:
> Hi Gao,
> 
> Thanks again for improving netns support for netfilter. Comments
> below:
> 
> On Thu, Feb 07, 2013 at 03:49:41PM +0800, Gao feng wrote:
>> Now,only init net has directroy /proc/net/netfilter,
>> this patch make this proc dentry pernet.
>>
>> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>> ---
>>  include/net/netns/x_tables.h |  3 +++
>>  net/netfilter/core.c         | 40 ++++++++++++++++++++++++++++++++++------
>>  2 files changed, 37 insertions(+), 6 deletions(-)
>>
>> diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
>> index c24060e..aa6a545 100644
>> --- a/include/net/netns/x_tables.h
>> +++ b/include/net/netns/x_tables.h
>> @@ -9,6 +9,9 @@ struct ebt_table;
>>  struct netns_xt {
>>  	struct list_head tables[NFPROTO_NUMPROTO];
>>  	bool notrack_deprecated_warning;
>> +#if defined CONFIG_PROC_FS
>> +	struct proc_dir_entry *proc_netfilter;
>> +#endif
> 
> This doesn't belong here to x_tables, it should be place in
> include/net/net_namespace.h.
> 

Get it,will fix it in next version.
Should I wait for the nf-next being open again?
