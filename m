From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 1/7] cgroups: Shrink struct cgroup_subsys
Date: Mon, 08 Nov 2010 13:23:18 +0800
Message-ID: <4CD78946.5060405__13896.4377031245$1289193786$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC146BA.7080009@cn.fujitsu.com>
	<AANLkTikf-1kLStxqi5UjP=vn3pqVBHy0OA7ibeWTkJ5z@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTikf-1kLStxqi5UjP=vn3pqVBHy0OA7ibeWTkJ5z-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

(Sorry for the delayed reply)

Paul Menage wrote:
> On Fri, Oct 22, 2010 at 1:09 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>> On x86_32, sizeof(struct cgroup_subsys) shrinks from 276 bytes
>> to 264.
>>
>> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> Maybe use "bool" here?
> 

Do you mean:

bool active;
bool disabled;
...

?

With alignment 5-8 bool values == 8 bytes in 64-bit machine, compared to
4 bytes with the approach this patch takes.

> Paul
> 
>> ---
>> include/linux/cgroup.h |   10 ++++++----
>>  1 files changed, 6 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
>> index ed4ba11..e23ded6 100644
>> --- a/include/linux/cgroup.h
>> +++ b/include/linux/cgroup.h
>> @@ -481,14 +481,16 @@ struct cgroup_subsys {
>>        void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
>>
>>        int subsys_id;
>> -       int active;
>> -       int disabled;
>> -       int early_init;
>> +
>> +       unsigned int active:1;
>> +       unsigned int disabled:1;
>> +       unsigned int early_init:1;
>>        /*
>>         * True if this subsys uses ID. ID is not available before cgroup_init()
>>         * (not available in early_init time.)
>>         */
>> -       bool use_id;
>> +       unsigned int use_id:1;
>> +
>>  #define MAX_CGROUP_TYPE_NAMELEN 32
>>        const char *name;
>>
>> --
>> 1.7.0.1
>>
>>
