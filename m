From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: Mapping PIDs from parent->child namespaces
Date: Wed, 05 Jan 2011 14:50:55 +0100
Message-ID: <4D24773F.8050800@free.fr>
References: <4D225579.6030106@fesnel.com> <4D23451B.6060807@free.fr>
	<4D234E77.6000605@free.fr> <4D23806C.5040806@fesnel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D23806C.5040806-ql8fK+M3D0TQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Heffner <mikeh-ql8fK+M3D0TQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/04/2011 09:17 PM, Mike Heffner wrote:
>> we use the following patch to get the pid of a task as seen from its
>> pid namespace. It can be useful to identify tasks writing pids in files.
>>
> 
> Great, I'll try it out. Has there been any interest in getting this into 
> the mainline? 

hmm, it has been talked over a few years ago. I can't find the pointer 
anymore. 

> Are there negatives to advertising child vpid's?

I don't think so but the issue is more on gathering clear requirements
for it.

The patch is simple enough to be discussed rapidly and eventually be 
accepted if it is considered useful enough. It does add a user/kernel 
API, which is always a concern. I'm not in favor of exposing too much
of the pid stuff, already overly complex with the nested pid namespace,
but the result of getpid() from a task pov sounds like a legitimate 
information to expose.
   
Why do you need it ? 

 
C.
