From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: namespaces?: bug at mm/slub.c:2750
Date: Wed, 11 Feb 2009 11:48:41 +0100
Message-ID: <19f34abd0902110248n22f8de12lccfa99faafafb942@mail.gmail.com>
References: <20090206113556.GA3161@alice>
	 <20090206161518.81e7d42c.akpm@linux-foundation.org>
	 <19f34abd0902102355o5bf51096o9aa3737e87104fb9@mail.gmail.com>
	 <20090211000740.f1de7cec.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756554AbZBKKsz@vger.kernel.org>
In-Reply-To: <20090211000740.f1de7cec.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Sesterhenn <snakebyte@gmx.de>, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Wed, Feb 11, 2009 at 9:07 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>> In case you missed it, KOSAKI Motohiro posted a similar stack-trace
>> (but not the same BUG) in this thread:
>> http://lkml.org/lkml/2009/2/10/7
>>
>
> Both traces include the newly-added put_cred_rcu().  Suspicious.
>

I have this test case which triggers it regularly after some minutes:

#include <sys/wait.h>
#include <sys/types.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char* argv[])
{
        unsigned int i;

        if (fork() == 0) {
                while (1)
                        system("echo -n .");
        }

        for (i = 0; i < 2; ++i) {
                if (fork() == 0) {
                        while (1) {
                                setreuid(0, 0xcafeba);
                                setreuid(0xcafeba, 0);

                                setreuid(0, 0xcafebb);
                                setreuid(0xcafebb, 0);
                        }

                        exit(EXIT_SUCCESS);
                }
        }

        while (!(wait(NULL) == -1 && errno == ECHILD))
                ;

        return 0;
}

It seems to be the combination of exec() and setreuid(), but I
couldn't get it to work with just exec() instead of system(). It is
possible that CONFIG_USER_SCHED must be =y for this to work. It can
probably be simplified too...


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
