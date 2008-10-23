From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: External checkpoint patch
Date: Thu, 23 Oct 2008 15:48:22 +0200
Message-ID: <490080A6.6020905@fr.ibm.com>
References: <1224612971.1848.193.camel@nimitz>
	<Pine.LNX.4.64.0810211857140.22085@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080901040502030909000202"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0810211857140.22085-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------080901040502030909000202
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Oren Laadan wrote:
>> Oren,
>>
>> Could you take a look over Cedric's external checkpoint patch?
>>
>> http://git.kernel.org/?p=linux/kernel/git/daveh/linux-2.6-cr.git;a=commit;h=28ffabbc17d3641eee2a7eb66f714c266c400263
>>
>> It seems pretty small to me.
>>
>> --
> 
> I committed a couple of patches on top of ckpt-v7 that do this.
> (the first one is actually a simple cleanup that is unrelated).
> 
> see:
> http://git.ncl.cs.columbia.edu/?p=linux-cr-dev.git;a=shortlog;h=refs/heads/ckpt-v7
> (or git://git.ncl.cs.columbia.edu/pub/git/linux-cr-dev.git ckpt-v7)
> 
> *  "Minor simplification of cr_ctx_alloc(), cr_ctx_free()"
> *  "External checkpoint of a task other than ourself"
> 
> To checkpoint another task, you need to freeze that other task, or to
> SIGSTOP it (if using a kernel without freezer cgroup).
> 
> Restart remains the same except the the original PID is not preserved
> (because we haven't solved yet the fork-with-specific-pid issue).
> 
> In reality, you would create a new names space, and have the task running
> in there call 'sys_restart()'.
> 
> Below are test1.c, ckpt.c (to checkpoint), and rstr.c (to restart), as
> well as the two patches.
> 
> I tested it this way:
> 	$ ./test.1 &
> 	[1] 3493
> 
> 	$ kill -STOP 3493
> 	$ ./ckpt 3493 > ckpt.image
> 	
> 	$ mv /tmp/cr-test.out /tmp/cr-test.out.orig
> 	$ cp /tmp/cr-test.out.orig /tmp/cr-test.out
> 
> 	$ kill -CONT 3493
> 
> 	$ ./rstr < ckpt.image
> now compare the output of the two output files


Oren, 

I've merged your v7 patches on top of the 2.6.27-lxc3 patchset : 

	http://lxc.sourceforge.net/patches/2.6.27/2.6.27-lxc3/

the -lxc patchset includes the just merged freezer and sysfs patches
required for the netns. 

the lxc user tools using the patchset are here (CVS head for the 
moment) : 

	 http://sourceforge.net/projects/lxc/

simple applications calculating decimals of PI (source attached) are 
successfully checkpointed and restarted with the lxc-checkpoint and 
lxc-restart tools. something like the following :

	$ lxc-create -n foo 
	$ lxc-start -n foo ./pi1 40000 &
	$ lxc-checkpoint -n foo > /tmp/statefile
	$ lxc-restart -n foo < /tmp/statefile

stdin should be closed of course and all output redirected to a regular 
file.

This is work in progress of course but it's a major milestone !

Thanks,

C.

--------------080901040502030909000202
Content-Type: text/x-csrc;
 name="pi1.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pi1.c"

/****************************************/
/* Compute pi to arbitrary precision    */
/* Author Roy Williams February 1994    */
/*   roy-NQQVC5OOd4osTUYHLfqkUA@public.gmane.org               */
/* Uses Machin's formula...             */
/* pi/4 = 4 arctan(1/5) - arctan(1/239) */
/****************************************/
/* compile with cc -O -o pi pi.c        */
/* run as "pi 1000" for 1000 digits     */
/****************************************/
/* The last few digits may be wrong.......... */

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <unistd.h>

void arctan(int *result, int *w1, int *w2, int denom, int onestep);
void mult(int *result, int factor);
void sub(int *result, int *decrem);
void print(int *result);
void mdiv(int *result, int denom);
void set(int *result, int rhs);
void copy(int *result, int *from);
void add(int *result, int *increm);
int zero(int *result);

#define BASE    10000
int nblock;
int *tot;
int *t1;
int *t2;
int *t3;

int main(int argc, char **argv)
{
        int ndigit = 60;
        if(argc == 2)
                ndigit = atoi(argv[1]);
        else {
                fprintf(stderr, "Usage: %s ndigit\n", argv[0]);
                fprintf(stderr, "(Assuming 60 digits)\n");
        }
        if(ndigit < 20) ndigit = 20;
        nblock = ndigit/4;
        tot = (int *)malloc(nblock*sizeof(int));
        t1 = (int *)malloc(nblock*sizeof(int));
        t2 = (int *)malloc(nblock*sizeof(int));
        t3 = (int *)malloc(nblock*sizeof(int));
        if(!tot || !t1 || !t2 || !t3){
                fprintf(stderr, "Not enough memory\n");
                exit(1);
        }
	printf("pi1 - %d digits, %.1f kbytes\n", ndigit,
	       (4*nblock*sizeof(int))/1024.0);
	
        arctan(tot, t1, t2, 5, 1);
        mult(tot, 4);
        arctan(t3, t1, t2, 239, 2);
        sub(tot, t3);
        mult(tot, 4);
        print(tot);
	return 0;
}

void arctan(int *result, int *w1, int *w2, int denom, int onestep)
{
        int denom2 = denom*denom;
        int k = 1;

        set(result, 1);
        mdiv(result, denom);
        copy(w1, result);

        do{
                if(onestep)
                        mdiv(w1, denom2);
                else {
                        mdiv(w1, denom);
                        mdiv(w1, denom);
                }
                copy(w2, w1);
                mdiv(w2, 2*k+1);
                if(k%2)
                        sub(result, w2);
                else
                        add(result, w2);
                k++;
		// add tracing PG
		//printf(":%d\n",k);

        } while(!zero(w2));
}

void copy(int *result, int *from)
{
        int i;
        for(i=0; i<nblock; i++)
                result[i] = from[i];
}

int zero(int *result)
{
        int i;
        for(i=0; i<nblock; i++)
                if(result[i])
                        return 0;
        return 1;
}

void add(int *result, int *increm)
{
        int i;
        for(i=nblock-1; i>=0; i--){
                result[i] += increm[i];
                if(result[i] >= BASE){
                        result[i] -= BASE;
                        result[i-1]++;
                }
        }
}

void sub(int *result, int *decrem)
{
        int i;
        for(i=nblock-1; i>=0; i--){
                result[i] -= decrem[i];
                if(result[i] < 0){
                        result[i] += BASE;
                        result[i-1]--;
                }
        }
}

void mult(int *result, int factor)
{
        int i, carry = 0;
        for(i=nblock-1; i>=0; i--){
                result[i] *= factor;
                result[i] += carry;
                carry = result[i]/BASE;
                result[i] %= BASE;
        }
}

void mdiv(int *result, int denom)
{
        int i, carry = 0;

        for(i=0; i<nblock; i++){
                result[i] += carry*BASE;
                carry = result[i] % denom;
                result[i] /= denom;
        }
}

void set(int *result, int rhs)
{
        int i;
        for(i=0; i<nblock; i++)
                result[i] = 0;
        result[0] = rhs;
}

void print(int *result)
{
        int i, k;
        char s[10];
        printf("%1d.\n", result[0]);
        for(i=1; i<nblock; i++){
                sprintf(s, "%4d ", result[i]);
                for(k=0; k<5; k++)
                        if(s[k] == ' ') s[k] = '0';
                printf("%c%c%c%c", s[0], s[1], s[2], s[3]);
                if(i%15 == 0) printf("\n");
        }
        printf("\n");
}

--------------080901040502030909000202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------080901040502030909000202--
