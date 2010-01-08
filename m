From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: LXC container,
	unmounting unneeded mount points (from the 	container namespace)
Date: Fri, 08 Jan 2010 15:35:20 +0100
Message-ID: <4B4742A8.1000708@free.fr>
References: <8e04b5821001080608w47b0529dhcd6f8a26e38f24e0@mail.gmail.com>	
	<4B473E89.1040200@free.fr>
	<8e04b5821001080625j22517f1i22ec3495d8d1e53b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8e04b5821001080625j22517f1i22ec3495d8d1e53b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Ciprian Dorin, Craciun" <ciprian.craciun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Ciprian Dorin, Craciun wrote:
> On Fri, Jan 8, 2010 at 4:17 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
>   
>> Ciprian Dorin, Craciun wrote:
>>     
>>>    Hy all!
>>>
>>>    Today I've started to play with the LXC containers, and I've got a
>>> question: when starting a container (with it's own mount point
>>> namespace), and I do a `cat /proc/mounts` I also see the mount points
>>> from my host system.
>>>
>>>    So the question is: how can I force `lxc-create` to remove any
>>> uneeded mount points (maybe all)?
>>>
>>>       
>> Committed today :)
>>
>> http://git.lab.toulouse-stg.fr.ibm.com/?p=lxc.git;a=commit;h=ed83715df7666879116d1657b1dd54a8fc6513f6
>>     

Oops, this one:

http://lxc.git.sourceforge.net/git/gitweb.cgi?p=lxc/lxc;a=commit;h=bf601689a9e0cea1ceaf17e4f7f853f5392c2827
