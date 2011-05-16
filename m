From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: Testing Linux-CR
Date: Mon, 16 May 2011 14:05:23 -0400
Message-ID: <4DD16763.2040603@cs.columbia.edu>
References: <BANLkTimLScFNe0POGBoQ8xD1OK=0OBiesA@mail.gmail.com>	<20110512221554.GA17723@mail.hallyn.com>
	<4DCDB2B1.9020608@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4DCDB2B1.9020608-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



On 05/13/2011 06:37 PM, Oren Laadan wrote:
> 
> 
> On 05/12/2011 06:15 PM, Serge E. Hallyn wrote:
>> Quoting Raghu D K (dk.raghu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>>> Dear All,
>>>
>>> I have cloned the following projects:
>>> linux-cr.git
>>> tests-cr.git
>>> user-cr.git
>>
>> Hi Raghu, glad you're giving it a shot.
>>
>> Oren, linux-cr.org doesn't show these trees any more?
> 
> It was broken for a bit.
> But the correct link is: http://www.linux-cr.org/git
> 
>>
>>> I have been successfully able to compile and boot of the Linux-2.6.37
>>> kernel. I am also able to build the library and test tools under the
>>> "tests-cr" and "user-cr" projects.
>>>
>>> However when I run the "ckpt" application from "/tests-cr/simple"
>>> folder I get an error in "/tmp/cr-test.out" stating checkpoint
>>> function not implemented.
>>>
>>> I am not sure if the "__NR_checkpoint" syscall has been implemented. 	
>>>
>>> Is there any documentation to refer or any clues to test this.
>>
>> You'll need to do 'make menuconfig', and make sure to set
>> CONFIG_CHECKPOINT=y.  See documentation under
>> linux-cr/Documentation/checkpoint as well.
> 
> I suspect it is because the cr.h header in tests-cr has not been
> updated in the past year (I manually fixed it here...). I'll send
> a patch promptly.

Actually, in the meanwhile you can do (in tests-cr):

./rewrite-cr-headers.sh -s PATH_TO_LINUX-CR > cr.h
make clean; make

I'll push a fix soon.

Oren.
