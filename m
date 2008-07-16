From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [BUG][cryo] Create file on restart ?
Date: Wed, 16 Jul 2008 13:59:23 -0700
Message-ID: <1216241963.4844.133.camel@localhost.localdomain>
References: <20080716185027.GA1335@us.ibm.com>
	<20080716192604.GA27454@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080716192604.GA27454-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


On Wed, 2008-07-16 at 14:26 -0500, Serge E. Hallyn wrote:
> Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > 
> > cryo does not (cannot ?) recreate files if the application created
> 
> I think that's for the best.
> 
> Don't you?

	I agree. I think drawing the line for process checkpoint/restart before
preserving the contents of mounted filesystems is very reasonable since
mounted filesystem(s) can already be preserved with your choice of
tool(s). I think it also gives us more options as far as using
checkpointed images for error recovery; if we take the concept of
checkpoint too far we may limit ourselves to merely reproducing errors
rather than also giving ourselves a means to recover from errors.

Cheers,
	-Matt Helsley

> -serge
> 
> > a file before checkpoint and the file does not exist at the time
> > of restart.
> > 
> > Note that the 'flags' field in '/proc/$pid/fdinfo/$fd' will not
> > have the O_CREAT (or O_TRUNC, O_EXCL, O_NOCTTY) flags. These
> > are cleared in __dentry_open()).
> > 
> > At the time of restart, is there a way for cryo to know that the
> > file must be created ?
> > 
> > To reproduce:
> > 	- run following program, 
> > 	- checkpoint after the first printf
> > 	- rm /tmp/foo1
> > 	- restart	# fails to open file during restart
> > 
> > ---
> > #include <stdio.h>
> > #include <unistd.h>
> > #include <errno.h>
> > #include <sys/fcntl.h>
> > 
> > main()
> > {
> > 	int fd;
> > 	int i;
> > 	char *buf = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
> > 
> > 	fd = open("/tmp/foo1", O_RDWR|O_CREAT|O_TRUNC, 0666);
> > 
> > 	if (fd < 0) {
> > 		perror("open");
> > 		exit(1);
> > 	}
> > 	printf("%d: Opened '/tmp/foo1', fd %d\n", getpid(), fd);
> > 	
> > 	for (i = 0; i < strlen(buf); i++) {
> > 		if (write(fd, &buf[i], 1) < 0) {
> > 			printf("Error %d writing %c to file, i %d\n",
> > 					errno, buf[i], i);
> > 			exit(1);
> > 		}
> > 		printf("%d: i %d, wrote %c\n", getpid(), i, buf[i]);
> > 		sleep(2);
> > 	}
> > }
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
