From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: + cgroups-fix-pid-namespace-bug.patch added to -mm tree
Date: Fri, 24 Jul 2009 13:59:58 +0800
Message-ID: <4A694DDE.3080605@cn.fujitsu.com>
References: <200907022320.n62NKpKO022860@imap1.linux-foundation.org>	<4A69461D.6080201@cn.fujitsu.com>
	<20090723225545.f2fd381a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090723225545.f2fd381a.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
> On Fri, 24 Jul 2009 13:26:53 +0800 Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 
>>> Subject: cgroups: fix pid namespace bug
>>> From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>>>
>> Hi Andrew,
>>
>> Could you queue this fix for .31.
> 
> Yup, I have it there already.
> 
>> I think there's no more objection to this patch or to queuing it
>> for .31 instead of .32. And then Benjamin can rebase his patchset
>> on top of it.
>>
> 
> I have a note here that Paul Menage said the patch had "missing operations". 
> Did that all get suitably resolved?
> 

Yes, resolved by the delta patch "cgroups-fix-pid-namespace-bug-fix.patch"
