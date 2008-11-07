From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 1/2][RFC] add socketat syscall
Date: Fri, 07 Nov 2008 13:19:47 +0100
Message-ID: <49143263.1040604__2162.20486113361$1226060535$gmane$org@fr.ibm.com>
References: <20081031215602.655672481@fr.ibm.com>	<20081031215900.810348746@fr.ibm.com>	<517f3f820811060522i7b3518aen47907a34b38adee9@mail.gmail.com>	<cfd18e0f0811060746l77fbe6fel83402ba543fccb38@mail.gmail.com>
	<491318DC.4000300@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <491318DC.4000300-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Subrata Modak <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> Michael Kerrisk wrote:
>>> On Fri, Oct 31, 2008 at 4:56 PM, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> wrote:
>>>> This patch adds the socketat syscall which allows to specify in
>>>> which network namespace we want to create a socket. The network
>>>> namespace destination is referred by a socket fd previously opened
>>>> in the destination network namespace.
>> Daniel,
>>
>> Is there any documentation for this system call, and/or test programs?
> 
> Not yet.
> 
> This small patch is a proposition to Andreas and Vivien to have a single 
> process being able to manage several network namespaces.
> 
> When a process unshares the network, it creates a socket which is used 
> as a socket control (it belongs to the network namespace). Each time a 
> network namespace is created, a socket control is created.
> 
> When the process has to create a socket for a specific network 
> namespace, it can use the socket control to specify it. This is the 
> purpose of the socketat syscall.

what about eric's proposal of adding an fd argument to sys_socket() ? was it 
dropped ?

C. 
