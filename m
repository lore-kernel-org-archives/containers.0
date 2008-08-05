From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Tue, 5 Aug 2008 11:32:38 +0200
Message-ID: <20080805093237.GB5027@localdomain>
References: <20080731155856.GH22403@hawkmoon.kerlabs.com>
	<4891E849.1050701@cs.columbia.edu>
	<20080731175058.GI22403@hawkmoon.kerlabs.com>
	<48920EA0.1060608@cs.columbia.edu>
	<20080801102600.GJ22403@hawkmoon.kerlabs.com>
	<48931A7E.1040302@cs.columbia.edu>
	<20080801180038.GL22403@hawkmoon.kerlabs.com>
	<48935B4D.7070302@cs.columbia.edu>
	<20080804101608.GA4081@localdomain>
	<4897BCE0.1080508@cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4897BCE0.1080508-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Aug 04, 2008 at 10:37:20PM -0400, Oren Laadan wrote:
> Louis Rilling wrote:
>> On Fri, Aug 01, 2008 at 02:51:57PM -0400, Oren Laadan wrote:
>>> Louis Rilling wrote:
>>>> On Fri, Aug 01, 2008 at 10:15:26AM -0400, Oren Laadan wrote:
>>> I actually wasn't thinking of streaming a series of incremental checkpoints
>>> (from base and on) to implement migration... I simply didn't have a use-case
>>> for that :)
>>
>> This could be useful however. Since incremental checkpoint is faster
>> this could reduce down-time.
>
> Naturally incremental checkpoint reduces downtime; however since each checkpoint
> is taken at a different time, they can be streamed -- transferred over the
> network -- as they are taken. This gives more flexibility and can still, if
> you wish, can easily be transformed to a single long stream.
>
> Actually, this is a good argument in favor of using multiple files: they are a
> more flexible approach and can always be easily transformed to a single long
> stream, while the reverse isn't so.

Yes the reverse is as easy: rebuilding a full checkpoint of a given id
#id consists simply in removing the records that are tagged as invalid as
from checkpoints having ids <= #id. This is actually what restart should
do :)

>>>> The point is that you need previous data when building an incremental
>>>> checkpoint, so you will read it at least. And since it was previously stored (in
>>> The scheme that I described above and is implemented in Zap does not require
>>> access to previous checkpoints when building a new incremental checkpoint.
>>> Instead, you keep some data structure in the kernel that describes the pieces
>>> that you need to carry with you (what pages were saved, and where; when a task
>>> exits, the data describing its mm will be discarded, of course, and so on).
>>
>> This is because you probably decided that a mechanism in the kernel that saves
>> storage space was not interesting if it does not improve speed. As a
>> consequence you need to keep metadata in kernel memory in order to do
>> incremental checkpoint. Maybe saving storage space without considering
>> speed could equally be done from userspace with sort of checkpoint diff
>> tools that would create an incremental checkpoint 2' from two full
>> checkpoints 1 and 2.
>
> Good point. In fact, the meta data is not only kept in memory, but also saved
> with each incremental checkpoint (well, its version at checkpoint time), so
> that restart would know where to find older data. So it is already transfered
> to user space; we may as well provide the option to keep it only in user space.

That is userspace should give it back to the kernel before doing the
next incremental checkpoint?

Louis

-- 
Dr Louis Rilling			Kerlabs - IRISA
Skype: louis.rilling			Campus Universitaire de Beaulieu
Phone: (+33|0) 2 99 84 71 52		Avenue du General Leclerc
Fax: (+33|0) 2 99 84 71 71		35042 Rennes CEDEX - France
http://www.kerlabs.com/
